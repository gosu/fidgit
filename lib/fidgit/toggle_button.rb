# encoding: utf-8

require_relative 'button'

module Fidgit
  class ToggleButton < Button
    DEFAULT_BORDER_COLOR_ON = Gosu::Color.new(255, 255, 0)
    DEFAULT_BORDER_COLOR_OFF = Gosu::Color.new(100, 100, 0)

    def on?; @on; end
    def on=(value); @on = value; update_status; end

    def initialize(parent, options = {}, &block)
      options = {
        on: false
      }.merge! options

      @on = options[:on]

      super(parent, options)

      @text_on = options[:text_on] || text
      @icon_on = options[:icon_on] || icon
      @tip_on = options[:tip_on] || tip
      @border_color_on = options[:border_color_on] || options[:border_color] || DEFAULT_BORDER_COLOR_ON

      @text_off = options[:text_off] || text
      @icon_off = options[:icon_off] || icon
      @tip_off = options[:tip_off] || tip
      @border_color_off = options[:border_color_off] || options[:border_color] || DEFAULT_BORDER_COLOR_OFF

      update_status
    end

    def clicked_left_mouse_button(sender, x, y)
      @on = (not @on)
      update_status

      super
    end

    protected
    def update_status
      if @on
        @text = @text_on
        @icon = @icon_on
        @tip = @tip_on
        @border_color = @border_color_on
      else
        @text = @text_off
        @icon = @icon_off
        @tip = @tip_off
        @border_color = @border_color_off
      end

      recalc

      nil
    end
  end
end