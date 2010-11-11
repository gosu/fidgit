# encoding: utf-8

require_relative 'label'

module Fidgit
  class ToolTip < Label
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(25, 25, 25)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgb(255, 255, 255)

    def x=(value); super(value); recalc; value; end
    def y=(value); super(value); recalc; value; end
    def hit?(x, y); false; end


    # @param (see Label#initialize)
    #
    # @option (see Label#initialize)
    def initialize(options = {}, &block)
      options = {
        z: Float::INFINITY,
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
        text: '',
      }.merge! options

      super(options[:text], options)
    end

    protected
    def layout
      super

      # Ensure the tip can't go over the edge of the screen. If it can't be avoided, align with left edge of screen.
      rect.x = [[x, $window.width - width - padding_x].min, 0].max
      rect.y = [[y, $window.height - height - padding_y].min, 0].max

      nil
    end
  end
end