# encoding: utf-8

require_relative 'event'

module Fidgit
  # An element within the GUI environment.
  # @abstract
  class Element
    include Event

    DEFAULT_FONT_SIZE = 15
    DEFAULT_PADDING_X, DEFAULT_PADDING_Y = 4, 4
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

    attr_reader :z, :tip, :font_size, :padding_x, :padding_y

    attr_accessor :parent

    @@fonts = {}
    def self.font(size = DEFAULT_FONT_SIZE)
      @@fonts[size] ||= Gosu::Font.new($window, nil, size)
    end

    def font; self.class.font @font_size; end
    def x; rect.x; end
    def x=(value); rect.x = value; end
    def y; rect.y; end
    def y=(value); rect.y = value; end
    def width; rect.width; end
    def height; rect.height; end
    def enabled?; @enabled; end
    def enabled=(value); @enabled = value; end

    @@debug_mode = false
    def self.debug_mode?; @@debug_mode; end
    def self.debug_mode=(value); @@debug_mode = value; end

    def rect; @rect; end; protected :rect
    def debug_mode?; @@debug_mode; end

    class << self
      alias_method :original_new, :new

      def new(*args, &block)
        obj = original_new(*args) # Block should be ignored.
        obj.send :post_init, &block
        obj
      end
    end

    def initialize(parent, options = {}, &block)
      options = {
        x: 0,
        y: 0,
        z: 0,
        width: 0,
        height: 0,
        tip: '',
        font_size: DEFAULT_FONT_SIZE,
        debug: @@debug_mode,
        background_color: DEFAULT_BACKGROUND_COLOR.dup,
        border_color: DEFAULT_BORDER_COLOR.dup,
        enabled: true,
      }.merge! options

      @enabled = options[:enabled]
      @background_color = options[:background_color]
      @border_color = options[:border_color]

      @padding_x = options[:padding_x] || options[:padding] || DEFAULT_PADDING_X
      @padding_y = options[:padding_y] || options[:padding] || DEFAULT_PADDING_Y
      @parent = parent
      @debug = options[:debug]

      @z = options[:z]
      @tip = options[:tip]
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
    def post_init(&block)
      recalc
      @parent.send :add, self if @parent
      yield self if block_given? # Return the result of the yield.
    end
  end
end