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

      super(parent, options)

      slider_width = width
      pack :vertical, spacing: 0 do
        @sliders = {}
        CHANNELS.each_with_index do |channel, i|
          @sliders[channel] = slider(value: @color.send(channel), range: 0..255, width: slider_width, tip: options[:channel_names][i]) do |sender, value|
            @color.send "#{channel}=", value
            @indicator.background_color = @color
            publish :changed, @color.dup
          end
        end

        @indicator = label '', background_color: @color, width: width, height: height + INDICATOR_HEIGHT
      end
    end

    protected
    # Use block as an event handler.
    def post_init_block(&block)
      subscribe :changed, &block
    end
  end
end