# encoding: utf-8

require_relative 'element'

module Fidgit
  # A composite element, made up of other elements (but manages them internally).
  class Composite < Element
    DEBUG_BORDER_COLOR = Gosu::Color.rgba(0, 255, 0, 100) # Color to draw an outline in when debugging layout.

    attr_reader :inner_container
    protected :inner_container

    def x=(value)
      @inner_container.x += value - x
      super(value)
    end

    def y=(value)
      @inner_container.y += value - y
      super(value)
    end

    def initialize(parent, inner_container, options = {})
      options[:border_color] = DEBUG_BORDER_COLOR if options[:debug] or debug_mode?

      @inner_container = inner_container
      @inner_container.parent = self

      super(parent, options)
    end

    # Returns the element within this composite that was hit.
    #
    # @return [Element, nil] The element hit, otherwise nil.
    def hit_element(x, y)
      @inner_container.hit_element(x, y)
    end

    def update
      @inner_container.update

      nil
    end

    protected
    def layout
      rect.width = @inner_container.width
      rect.height = @inner_container.height

      nil
    end

    protected
    def draw_foreground
      @inner_container.draw

      font.draw self.class.name, x, y, z if debug_mode?

      nil
    end
  end
end