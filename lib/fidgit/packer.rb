# encoding: utf-8

require_relative 'container'

module Fidgit
  # Container that auto-packs elements.
  #
  # @abstract
  class Packer < Container
    DEFAULT_SPACING_X, DEFAULT_SPACING_Y = 5, 5

    attr_reader :spacing_x, :spacing_y

    def initialize(parent, options = {})
      options = {
      }.merge! options

      @spacing_x = options[:spacing_x] || options[:spacing] || DEFAULT_SPACING_X
      @spacing_y = options[:spacing_y] || options[:spacing] || DEFAULT_SPACING_Y

      super(parent, options)
    end

    # Recalculate the size of the container.
    # Should be overridden by any descendant that manages the positions of its children.
    protected
    def layout
      # This assumes that the container overlaps all the children.

      # Move all children if we have moved.
      @children.each.with_index do |child, index|
        child.x = x + padding_x
        child.y = y + padding_y
      end

      # Make us as wrap around the largest child.
      rect.width = (@children.map {|c| c.width }.max || 0) + padding_x * 2
      rect.height = (@children.map {|c| c.height }.max || 0) + padding_y * 2

      super
    end
  end
end