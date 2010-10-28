# encoding: utf-8

require_relative 'element'

module Fidgit
  # A container that contains Elements.
  # @abstract
  class Container < Element
    DEBUG_BORDER_COLOR = Gosu::Color.rgba(0, 0, 255, 100) # Color to draw an outline in when debugging layout.

    def size; @children.size; end
    def each(&block); @children.each &block; end
    def find(&block); @children.find &block; end
    def index(value); @children.index value; end
    def [](index); @children[index]; end

    def x=(value)
      each {|c| c.x += value - x }
      super(value)
    end

    def y=(value)
      each {|c| c.y += value - y }
      super(value)
    end

    def initialize(parent, options = {})
      options[:border_color] = DEBUG_BORDER_COLOR if options[:debug] or debug_mode?

      @children = []

      super(parent, options)
    end

    def add(element)
      element.send :parent=, self
      @children.push element

      recalc
      nil
    end

    def remove(element)
      @children.delete element
      element.send :parent=, nil

      recalc
      nil
    end

    def clear
      @children.each {|child| child.parent = nil }
      @children.clear

      recalc

      nil
    end

    def update
      each { |c| c.update }

      nil
    end

    # Returns the element within this container that was hit,
    # @return [Element, nil] The element hit, otherwise nil.
    def hit_element(x, y)
      @children.reverse_each do |child|
        case child
        when Container, Composite
          if element = child.hit_element(x, y)
            return element
          end
        else
          return child if child.hit?(x, y)
        end
      end

      nil
    end

    protected
    def draw_foreground
      each { |c| c.draw }

      font.draw self.class.name, x, y, z if debug_mode?

      nil
    end
  end
end