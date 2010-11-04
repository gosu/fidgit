# encoding: utf-8

require_relative 'label'

module Fidgit
  class Button < Label
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(100, 100, 100)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgb(150, 150, 150)
    DEFAULT_COLOR = Gosu::Color.rgb(255, 255, 255)

    HOVER_COLOR = Gosu::Color.rgb(150, 150, 150)
    DISABLED_COLOR = Gosu::Color.rgb(150, 150, 150)

    # @param (see Label#initialize)
    # @option (see Label#initialize)
    def initialize(parent, options = {}, &block)
      options = {
        color: DEFAULT_COLOR,
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
        text: '',
      }.merge! options

      super(parent, options[:text], options)

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
        HOVER_COLOR
      else
        DEFAULT_BACKGROUND_COLOR
      end

      @color = if enabled?
        DEFAULT_COLOR
      else
        DISABLED_COLOR
      end

      nil
    end
  end
end