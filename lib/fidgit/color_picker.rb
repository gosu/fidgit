# encoding: utf-8

require_relative 'composite'

module Fidgit
  class ColorPicker < Composite
    DEFAULT_COLOR = Gosu::Color.rgba(255, 255, 255, 255)
    CHANNELS = [:red, :green, :blue]
    DEFAULT_CHANNEL_NAMES = CHANNELS.map {|c| c.to_s.capitalize }

    INDICATOR_HEIGHT = 20

    def color; @color.dup; end

    def color=(value)
      @color = value.dup
      CHANNELS.each do |channel|
        @sliders[channel].value = @color.send channel
      end

      publish :changed, @color.dup

      value
    end

    # @param (see Composite#initialize)
    # @option (see Composite#initialize)
    def initialize(parent, options = {}, &block)
      options = {
        padding: 0,
        spacing: 0,
        channel_names: DEFAULT_CHANNEL_NAMES,
        color: DEFAULT_COLOR,
      }.merge! options

      @color = options[:color].dup

      super(parent, VerticalPacker.new(nil, spacing: 0), options)

      @sliders = {}
      slider_width = width
      CHANNELS.each_with_index do |channel, i|
        Slider.new(inner_container, value: @color.send(channel), range: 0..255, width: slider_width, tip: options[:channel_names][i]) do |slider|
          slider.subscribe :changed do |sender, value|
            @color.send "#{channel}=", value
            publish :changed, @color.dup
          end

          @sliders[channel] = slider
        end
      end
    end

    protected
    def layout
      super
      rect.height += INDICATOR_HEIGHT

      nil
    end

    protected
    def draw_foreground
      super

      sliders_height = @sliders[:red].height * @sliders.size

      draw_rect x, y + sliders_height, width, INDICATOR_HEIGHT, z, @color

      nil
    end
  end
end