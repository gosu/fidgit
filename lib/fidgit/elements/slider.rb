# encoding: utf-8

require_relative 'container'

module Fidgit
  class Slider < Composite
    # @private
    class Handle < Element
      DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(255, 0, 0)
      DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

      # @param (see Element#initialize)
      #
      # @option (see Element#initialize)
      def initialize(parent, options = {}, &block)
        options = {
          background_color: DEFAULT_BACKGROUND_COLOR,
          border_color: DEFAULT_BORDER_COLOR,
        }.merge! options

        super parent, options
      end
    end

    handles :changed

    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(100, 100, 100, 255)
    DEFAULT_GROOVE_COLOR = Gosu::Color.rgb(200, 200, 200)
    DEFAULT_HANDLE_COLOR = Gosu::Color.rgb(255, 0, 0)

    attr_reader :value, :range

    # @param (see Composite#initialize)
    #
    # @option (see Composite#initialize)
    # @option options [Range] :range (0..1.0)
    # @option options [Range] :value (minimum of :range)
    def initialize(parent, options = {}, &block)
      options = {
        range: 0..1.0,
        height: 25,
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
        groove_color: DEFAULT_GROOVE_COLOR,
        handle_color: DEFAULT_HANDLE_COLOR,
        groove_thickness: 5,
      }.merge! options

      @range = options[:range].dup
      @groove_color = options[:groove_color].dup
      @groove_thickness = options[:groove_thickness]
      @continuous = @range.min.is_a?(Float) or @range.max.is_a?(Float)

      super(parent, options)

      # TODO: This should probably be done with proper dragging, but will do for now.
      subscribe :hover do |sender, x, y|
        left_mouse_button(sender, x, y) if $window.button_down? Gosu::MsLeft
      end

      @handle = Handle.new(self, width: (height / 2 - padding_x), height: height - padding_y * 2,
                           background_color: options[:handle_color])

      self.value = options.has_key?(:value) ? options[:value] : @range.min
    end

    def value=(value)
      @value = @continuous ? value.to_f : value.round
      @value = [[@value, @range.min].max, @range.max].min
      @handle.x = x + padding_x + ((width - @handle.width) * (@value - @range.min) / (@range.max - @range.min).to_f)
      publish :changed, @value

      @value
    end

    def tip
      tip = super
      tip.empty? ? @value.to_s : "#{tip}: #{@value}"
    end

    def left_mouse_button(sender, x, y)
      self.value = ((x - self.x - (@handle.width / 2)) / (width - @handle.width)) * (@range.max - @range.min) + @range.min
      @mouse_down = true

      nil
    end

    def hit_element(x, y)
      if @handle.hit?(x, y)
        self # TODO: should pass this to the handle, so it can be dragged.
      elsif hit?(x, y)
        self
      else
        nil
      end
    end

    protected
    # Prevent standard packing layout change.
    def layout
      nil
    end

    protected
    def draw_background
      super
      # Draw a groove for the handle to move along.
      draw_rect x + (@handle.width / 2), y + (height - @groove_thickness) / 2, width - @handle.width, @groove_thickness, z, @groove_color
      nil
    end

    protected
    # Use block as an event handler.
    def post_init_block(&block)
      subscribe :changed, &block
    end
  end
end