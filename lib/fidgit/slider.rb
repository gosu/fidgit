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

    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
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
      }.merge! options

      @range = options[:range].dup
      @groove_color = options[:groove_color].dup

      super(parent, options)

      HorizontalPacker.new(self, padding: 0) do |packer|
        @handle = Handle.new(packer, width: (height / 2 - padding_x), height: height - padding_y * 2,
                           background_color: options[:handle_color])
      end

      self.value = options.has_key?(:value) ? options[:value] : @range.min
    end

    def value=(value)
      raise ArgumentError, "value (#{value}} must be within range #{@range}" unless @range.include? value
      @value = value
      @handle.x = x + padding_x + ((width - padding_x * 2) * ((value - @range.min) / (@range.max - @range.min).to_f) - @handle.width / 2).round
      publish :changed, value

      @value
    end

    def tip
      tip = super
      tip.empty? ? @value.to_s : "#{tip}: #{@value}"
    end

    def left_mouse_button(sender, x, y)
      value = (((x - self.x - padding_x) / (width - padding_x * 2)) * (@range.max - @range.min) + @range.min).to_i
      self.value = [[value, @range.max].min, @range.min].max
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
      draw_rect x + padding_x, y + padding_y, width - padding_x * 2, height - padding_y * 4, z, @groove_color
      nil
    end
  end
end