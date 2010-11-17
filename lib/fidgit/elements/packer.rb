# encoding: utf-8

require_relative 'container'

module Fidgit
  # Container that auto-packs elements.
  #
  # @abstract
  class Packer < Container
    attr_reader :spacing_h, :spacing_v

    # @param (see Container#initialize)
    #
    # @option (see Container#initialize)
    def initialize(options = {})
      options = {
      }.merge! options

      @spacing_h = options[:spacing_h] || options[:spacing] || default(:spacing_h)
      @spacing_v = options[:spacing_v] || options[:spacing] || default(:spacing_v)

      super(options)
    end

    protected
    # Recalculate the size of the container.
    # Should be overridden by any descendant that manages the positions of its children.
    def layout
      # This assumes that the container overlaps all the children.

      # Move all children if we have moved.
      @children.each.with_index do |child, index|
        child.x = padding_left + x
        child.y = padding_top + y
      end

      # Make us as wrap around the largest child.
      rect.width = (@children.map {|c| c.width }.max || 0) + padding_left + padding_right
      rect.height = (@children.map {|c| c.height }.max || 0) + padding_top + padding_bottom

      super
    end
  end
end