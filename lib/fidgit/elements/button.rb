# encoding: utf-8

module Fidgit
  class Button < Label
    # @param (see Label#initialize)
    # @option (see Label#initialize)
    def initialize(text, options = {}, &block)
      options = {
        color: default(:color),
        background_color: default(:background_color),
        border_color: default(:border_color),
      }.merge! options

      super(text, options)

      update_colors
    end

    def clicked_left_mouse_button(sender, x, y)
      # TODO: Play click sound?
      nil
    end

    def enabled=(value)
      super(value)
      update_colors

      value
    end

    def enter(sender)
      @mouse_over = true
      update_colors

      nil
    end

    def leave(sender)
      @mouse_over = false
      update_colors

      nil
    end

    protected
    def update_colors
      @background_color = if @mouse_over and enabled?
        default(:hover, :background_color)
      else
        default(:background_color)
      end

      @color = if enabled?
        default(:color)
      else
        default(:disabled, :color)
      end

      nil
    end

    protected
    # A block added to any button subscribes to LMB click.
    def post_init_block(&block)
      subscribe :clicked_left_mouse_button, &block
    end
  end
end