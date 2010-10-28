# encoding: utf-8

require_relative 'packer'

module Fidgit
  # A vertically aligned element packing container.
  class VerticalPacker < Packer
    protected
    def layout
      total_height = padding_y

      @children.each.with_index do |child, index|
        child.x = x + padding_x
        child.y = y + total_height
        total_height += child.height
        total_height += spacing_y unless index == @children.size - 1
      end

      rect.height = total_height + padding_y
      rect.width = (@children.map {|c| c.width }.max || 0) + (padding_x * 2)

      nil
    end
  end
end