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

    handles :left_mouse_button
    handles :pressed_left_mouse_button
    handles :holding_left_mouse_button
    handles :released_left_mouse_button
    handles :clicked_left_mouse_button
    
    handles :right_mouse_button
    handles :pressed_right_mouse_button
    handles :holding_right_mouse_button
    handles :released_right_mouse_button
    handles :clicked_right_mouse_button
    
    handles :mouse_wheel_up
    handles :mouse_wheel_down

    handles :enter
    handles :hover
    handles :leave

    DEFAULT_PADDING_X, DEFAULT_PADDING_Y = 4, 4
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

    attr_reader :z, :tip, :font_size, :padding_x, :padding_y, :redirector

    attr_accessor :parent

    def x; rect.x; end
    def x=(value); rect.x = value; end
    def y; rect.y; end
    def y=(value); rect.y = value; end
    def width; rect.width; end
    def height; rect.height; end
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
    # @option options [Number] :width (0)
    # @option options [Number] :height (0)
    # @option options [String] :tip ('') Tool-tip text
    # @option options [String] :font_name ('')
    # @option options [String] :font_size (Fidgit.default_font_size)
    # @option options [String] :debug (Fidgit.debug_mode?)
    # @option options [Gosu::Color] :background_color (transparent)
    # @option options [Gosu::Color] :border_color (transparent)
    # @option options [Boolean] :enabled (true)
    # @option options [Number] :padding (4)
    # @option options [Number] :padding_x (:padding option)
    # @option options [Number] :padding_y (:padding option)
    #
    # @yield instance_methods_eval with respect to self.
    def initialize(parent, options = {}, &block)
      options = {
        x: 0,
        y: 0,
        z: 0,
        width: 0,
        height: 0,
        tip: '',
        font_name: Fidgit.default_font_name,
        font_size: Fidgit.default_font_size,
        debug: Fidgit.debug_mode?,
        background_color: DEFAULT_BACKGROUND_COLOR.dup,
        border_color: DEFAULT_BORDER_COLOR.dup,
        enabled: true,
      }.merge! options

      @enabled = options[:enabled]
      @background_color = options[:background_color].dup
      @border_color = options[:border_color].dup

      @padding_x = options[:padding_x] || options[:padding] || DEFAULT_PADDING_X
      @padding_y = options[:padding_y] || options[:padding] || DEFAULT_PADDING_Y
      @parent = parent
      @debug = options[:debug]

      @z = options[:z]
      @tip = options[:tip].dup
      @font_name = options[:font_name].dup
      @font_size = options[:font_size]

      @rect = Chingu::Rect.new(0, 0, options[:width], options[:height])
      self.x, self.y = options[:x], options[:y]
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