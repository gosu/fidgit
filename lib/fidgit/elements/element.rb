# encoding: utf-8

require_relative '../event'

# The Fidgit GUI framework for Gosu.
module Fidgit
  class << self
    attr_accessor :default_font_name, :default_font_size, :fonts, :debug_mode
  end

  self.default_font_name = '' # Just use the default Gosu font.
  self.default_font_size = 15
  self.fonts = Hash.new { |fonts, name| fonts[name] = Hash.new { |sizes, size| sizes[size] = Gosu::Font.new($window, name, size) } }
  self.debug_mode = false

  def self.debug_mode?; debug_mode; end

  # An element within the GUI environment.
  # @abstract
  class Element
    include Event

    event :left_mouse_button
    event :holding_left_mouse_button
    event :released_left_mouse_button
    event :clicked_left_mouse_button
    
    event :right_mouse_button
    event :holding_right_mouse_button
    event :released_right_mouse_button
    event :clicked_right_mouse_button
    
    event :mouse_wheel_up
    event :mouse_wheel_down

    event :enter
    event :hover
    event :leave

    DEFAULT_PADDING_X, DEFAULT_PADDING_Y = 4, 4
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

    VALID_ALIGN_H = [:left, :center, :right, :fill]
    DEFAULT_ALIGN_H = :left
    VALID_ALIGN_V = [:top, :center, :bottom, :fill]
    DEFAULT_ALIGN_V = :top

    attr_reader :z, :tip, :font_size, :padding_x, :padding_y, :redirector, :align_h, :align_v, :parent

    attr_accessor :background_color

    def x; rect.x; end
    def x=(value); rect.x = value; end

    def y; rect.y; end
    def y=(value); rect.y = value; end

    def width; rect.width; end
    def width=(value); rect.width = [[value, @width_range.max].min, @width_range.min].max; end
    def min_width; @width_range.min; end
    def max_width; @width_range.max; end

    def height; rect.height; end
    def height=(value); rect.height = [[value, @height_range.max].min, @height_range.min].max; end
    def min_height; @height_range.min; end
    def max_height; @height_range.max; end

    # Can the object be dragged?
    def drag?(button); false; end

    def enabled?; @enabled; end
    def enabled=(value); @enabled = value; end
    def debug_mode?; @debug_mode; end

    def font; Fidgit.fonts[@font_name][@font_size]; end

    def rect; @rect; end; protected :rect

    class << self
      alias_method :original_new, :new

      def new(*args, &block)
        obj = original_new(*args) # Block should be ignored.
        obj.send :post_init
        obj.send :post_init_block, &block if block_given?
        obj
      end
    end

    # @param [Element, nil] parent
    #
    # @option options [Number] :x (0)
    # @option options [Number] :y (0)
    # @option options [Number] :z (0)
    #
    # @option options [Number] :width (auto)
    # @option options [Number] :min_width (value of :width option)
    # @option options [Number] :max_width (value of :width option)
    #
    # @option options [Number] :height (auto)
    # @option options [Number] :min_height (value of :height option)
    # @option options [Number] :max_height (value of :height option)
    #
    # @option options [String] :tip ('') Tool-tip text
    # @option options [String] :font_name ('')
    # @option options [String] :font_size (Fidgit.default_font_size)
    # @option options [String] :debug (Fidgit.debug_mode?)
    #
    # @option options [Gosu::Color] :background_color (transparent)
    # @option options [Gosu::Color] :border_color (transparent)
    #
    # @option options [Boolean] :enabled (true)
    #
    # @option options [Number] :padding (4)
    # @option options [Number] :padding_x (:padding option)
    # @option options [Number] :padding_y (:padding option)
    #
    # @option options [Symbol] :align Align both horizontally and vertically. One of :center, :fill or [<align_v>, <align_h>] such as [:top, :right].
    # @option options [Symbol] :align_h (value or :align else :left) One of :left, :center, :right :fill
    # @option options [Symbol] :align_v (value of :align else :top) One of :top, :center, :bottom, :fill

    # @yield instance_methods_eval with respect to self.
    def initialize(options = {}, &block)
      options = {
        x: 0,
        y: 0,
        z: 0,
        tip: '',
        font_name: Fidgit.default_font_name,
        font_size: Fidgit.default_font_size,
        debug: Fidgit.debug_mode?,
        background_color: DEFAULT_BACKGROUND_COLOR.dup,
        border_color: DEFAULT_BORDER_COLOR.dup,
        enabled: true,
      }.merge! options

      @enabled = options[:enabled]

      # Alignment and min/max dimensions.
      @align_h = options[:align_h] || Array(options[:align]).last || DEFAULT_ALIGN_H
      raise ArgumentError, "Invalid align_h: #{@align_h}" unless VALID_ALIGN_H.include? @align_h

      min_width = (options[:min_width] || options[:width] || 0)
      max_width = (options[:max_width] || options[:width] || Float::INFINITY)
      @width_range = min_width..max_width                                         

      @align_v = options[:align_v] || Array(options[:align]).first || DEFAULT_ALIGN_V
      raise ArgumentError, "Invalid align_v: #{@align_v}" unless VALID_ALIGN_V.include? @align_v

      min_height = (options[:min_height] || options[:height] || 0)
      max_height = (options[:max_height] || options[:height] || Float::INFINITY)
      @height_range = min_height..max_height

      @background_color = options[:background_color].dup
      @border_color = options[:border_color].dup

      @padding_x = options[:padding_x] || options[:padding] || DEFAULT_PADDING_X
      @padding_y = options[:padding_y] || options[:padding] || DEFAULT_PADDING_Y
      self.parent = options[:parent]
      @debug = options[:debug]

      @z = options[:z]
      @tip = options[:tip].dup
      @font_name = options[:font_name].dup
      @font_size = options[:font_size]

      @rect = Chingu::Rect.new(options[:x], options[:y], options[:width] || 0, options[:height] || 0)
    end

    def recalc
      old_width, old_height = width, height
      layout
      parent.recalc if parent and (width != old_width or height != old_height)

      nil
    end

    # Check if a point (screen coordinates) is over the element.
    def hit?(x, y)
      @rect.collide_point?(x, y)
    end

    # Redraw the element.
    def draw
      draw_background
      draw_border
      draw_foreground
      nil
    end

    # Update the element.
    def update
      nil
    end

    def draw_rect(*args)
      $window.current_game_state.draw_rect(*args)
    end

    def draw_frame(*args)
      $window.current_game_state.draw_frame(*args)
    end

    protected
    def parent=(parent); @parent = parent; end

    protected
    def draw_background
      draw_rect(x, y, width, height, z, @background_color) unless @background_color.transparent?
    end

    protected
    def draw_border
      draw_frame(x, y, width, height, z, @border_color) unless @border_color.transparent?
    end

    protected
    def draw_foreground
      nil
    end

    protected
    # Should be overridden in children to recalculate the width and height of the element and, if a container
    # manage the positions of its children.
    def layout
      nil
    end

    protected
    def post_init
      recalc
      @parent.send :add, self if @parent
    end

    protected
    # By default, elements do not accept block arguments.
    def post_init_block(&block)
      raise ArgumentError, "does not accept a block"
    end
  end
end