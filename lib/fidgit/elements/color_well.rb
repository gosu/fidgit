# encoding: utf-8

require_relative 'radio_button'

module Fidgit
  class ColorWell < RadioButton
    alias_method :color, :value

    # @param (see RadioButton#initialize)
    # @option (see RadioButton#initialize)
    def initialize(options = {}, &block)
      options = {
        width: default(:width),
        height: default(:height),
        color: default(:color),
        outline_color: default(:outline_color),
        checked_border_color: default(:checked, :border_color),
      }.merge! options

      @outline_color = options[:outline_color].dup

      super('', (options[:color] || options[:value]).dup, options)
    end

    protected
    def draw_background
      super

      draw_frame x + 2, y + 2, width - 4, height - 4, 1, z, @outline_color

      nil
    end

    protected
    def draw_foreground
      draw_rect x + 3, y + 3, width - 6, height - 6, z, value

      nil
    end
  end
end