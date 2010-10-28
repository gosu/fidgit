# encoding: utf-8

require_relative 'label'

module Fidgit
  class ToolTip < Label
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(25, 25, 25)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgb(255, 255, 255)

    def x=(value); super(value); recalc; value; end
    def y=(value); super(value); recalc; value; end
    def hit?(x, y); false; end

    def initialize(parent, options = {}, &block)
      options = {
        background_color: DEFAULT_BACKGROUND_COLOR.dup,
        border_color: DEFAULT_BORDER_COLOR.dup
      }.merge! options

      super(parent, options)
    end

    protected
    def layout
      super

      # Ensure the tip can't go over the edge of the screen.
      rect.x = [x, $window.width - width - padding_x].min
      rect.y = [y, $window.height - height - padding_y].min

      nil
    end
  end
end