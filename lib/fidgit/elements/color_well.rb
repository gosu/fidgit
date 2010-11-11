# encoding: utf-8

require_relative 'radio_button'

module Fidgit
  class ColorWell < RadioButton
    DEFAULT_COLOR = Gosu::Color.rgb(0, 0, 0)
    DEFAULT_BORDER_COLOR_CHECKED = Gosu::Color.rgb(255, 255, 255)
    DEFAULT_BORDER_COLOR_UNCHECKED = Gosu::Color.rgb(100, 100, 100)

    OUTLINE_COLOR = Gosu::Color.rgb(0, 0, 0)

    DEFAULT_SIZE = 20

    # @param (see RadioButton#initialize)
    # @option (see RadioButton#initialize)
    def initialize(options = {}, &block)
      options = {
        width: DEFAULT_SIZE,
        height: DEFAULT_SIZE,
        color: DEFAULT_COLOR,
        border_color_checked: DEFAULT_BORDER_COLOR_CHECKED,
        border_color_unchecked: DEFAULT_BORDER_COLOR_UNCHECKED,
      }.merge! options

      super(nil, options)

      @value = (options[:color] || options[:value]).dup
    end

    protected
    def draw_background
      super

      draw_frame x + 2, y + 2, width - 4, height - 4, z, OUTLINE_COLOR

      nil
    end

    protected
    def draw_foreground
      draw_rect x + 3, y + 3, width - 6, height - 6, z, @value

      nil
    end
  end
end