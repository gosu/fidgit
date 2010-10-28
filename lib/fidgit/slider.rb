# encoding: utf-8

require_relative 'container'

module Fidgit
  class Slider < Composite
    # @private
    class Handle < Element
      DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(255, 0, 0)
      DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

      protected
      def initialize(parent, options = {}, &block)
        options = {
          background_color: DEFAULT_BACKGROUND_COLOR.dup,
          border_color: DEFAULT_BORDER_COLOR.dup,
        }.merge! options

        super parent, options
      end
    end

    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_GROOVE_COLOR = Gosu::Color.rgb(200, 200, 200)
    DEFAULT_HANDLE_COLOR = Gosu::Color.rgb(255, 0, 0)

    attr_reader :value, :range

    # @option options [Range] :range (0..1.0)
    # @option options [Range] :value (minimum of :range)
    def initialize(parent, options = {}, &block)
      options = {
        range: 0..1.0,
        height: 25,
        background_color: DEFAULT_BACKGROUND_COLOR.dup,
        border_color: DEFAULT_BORDER_COLOR.dup,
        groove_color: DEFAULT_GROOVE_COLOR.dup,
        handle_color: DEFAULT_HANDLE_COLOR.dup,
      }.merge! options

      @range = options[:range]
      @groove_color = options[:groove_color]

      super(parent, HorizontalPacker.new(nil, padding: 0), options)

      @handle = Handle.new(inner_container, width: (height / 2 - padding_x), height: height - padding_y * 2,
                           background_color: options[:handle_color])

      self.value = options[:value] ? options[:value] : @range.min
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

    def draw_background
      super
      draw_rect x + padding_x, y + padding_y, width - padding_x * 2, height - padding_y * 4, z, @groove_color
      nil
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
  end
end