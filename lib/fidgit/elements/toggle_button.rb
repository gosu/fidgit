# encoding: utf-8

require_relative 'button'

module Fidgit
  # A button that toggles its value from false<->true when clicked.
  class ToggleButton < Button
    DEFAULT_BORDER_COLOR_ON = Gosu::Color.new(255, 255, 0)
    DEFAULT_BORDER_COLOR_OFF = Gosu::Color.new(100, 100, 0)

    handles :changed

    attr_reader :value
    def value=(value); @value = value; update_status; end

    # @param (see Button#initialize)
    #
    # @option (see Button#initialize)
    def initialize(options = {}, &block)
      options = {
        value: false
      }.merge! options

      @value = options[:value]

      super(options)

      @text_on = (options[:text_on] || text).dup
      @icon_on = options[:icon_on] || icon
      @tip_on = (options[:tip_on] || tip).dup
      @border_color_on = (options[:border_color_on] || options[:border_color] || DEFAULT_BORDER_COLOR_ON).dup

      @text_off = (options[:text_off] || text).dup
      @icon_off = options[:icon_off] || icon
      @tip_off = (options[:tip_off] || tip).dup
      @border_color_off = (options[:border_color_off] || options[:border_color] || DEFAULT_BORDER_COLOR_OFF).dup

      update_status

      subscribe :clicked_left_mouse_button do |sender, x, y|
        @value = (not @value)
        update_status
        publish :changed, @value
      end
    end

    protected
    # The block for a toggle-button is connected to :changed event.
    def post_init_block(&block)
      subscribe :changed, &block
    end

    protected
    def update_status
      if @value
        @text = @text_on.dup
        @icon = @icon_on ? @icon_on.dup : nil
        @tip = @tip_on.dup
        @border_color = @border_color_on.dup
      else
        @text = @text_off.dup
        @icon = @icon_off ? @icon_off.dup : nil
        @tip = @tip_off.dup
        @border_color = @border_color_off.dup
      end

      recalc

      nil
    end
  end
end