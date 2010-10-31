# encoding: utf-8

require_relative 'button'

module Fidgit
  class ToggleButton < Button
    DEFAULT_BORDER_COLOR_ON = Gosu::Color.new(255, 255, 0)
    DEFAULT_BORDER_COLOR_OFF = Gosu::Color.new(100, 100, 0)

    def on?; @on; end
    def on=(value); @on = value; update_status; end

    # @param (see Button#initialize)
    #
    # @option (see Button#initialize)
    def initialize(parent, options = {}, &block)
      options = {
        on: false
      }.merge! options

      @on = options[:on]

      super(parent, options)

      @text_on = (options[:text_on] || text).dup
      @icon_on = options[:icon_on] || icon
      @tip_on = (options[:tip_on] || tip).dup
      @border_color_on = (options[:border_color_on] || options[:border_color] || DEFAULT_BORDER_COLOR_ON).dup

      @text_off = (options[:text_off] || text).dup
      @icon_off = options[:icon_off] || icon
      @tip_off = (options[:tip_off] || tip).dup
      @border_color_off = (options[:border_color_off] || options[:border_color] || DEFAULT_BORDER_COLOR_OFF).dup

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