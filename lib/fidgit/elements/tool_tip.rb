# encoding: utf-8

require_relative 'label'

module Fidgit
  class ToolTip < Label
    def x=(value); super(value); recalc; value; end
    def y=(value); super(value); recalc; value; end
    def hit?(x, y); false; end


    # @param (see Label#initialize)
    #
    # @option (see Label#initialize)
    def initialize(options = {}, &block)
      options = {
        z: Float::INFINITY,
        background_color: default(:background_color),
        border_color: default(:border_color),
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