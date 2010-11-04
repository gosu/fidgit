# encoding: utf-8

require_relative 'packer'

module Fidgit
  # A vertically aligned element packing container.

  class GridPacker < Packer
    # @return [Integer]
    def num_rows; (size / @num_columns.to_f).ceil; end
    # @return [Integer]
    def num_columns; @num_columns; end

    # @note Currently only supports +num_columns+ mode (not +num_rows+).
    #
    # @param (see Packer#initialize)
    #
    # @option (see Packer#initialize)
    # @option options [Integer] :num_columns (1) Maximum number of columns to use (incompatible with :num_rows)
    # @option options [Integer] :num_rows Maximum number of rows to use (incompatible with :num_columns)
    def initialize(parent, options = {})
      options = {
        num_columns: 1,
      }.merge! options

      @num_columns = options[:num_columns]

      super parent, options
    end

    protected
    def layout
      # Calculate the maximum size of each cell.
      widths = Array.new(num_columns)
      heights = Array.new(num_rows)

      @children.each_slice(num_columns).with_index do |row, row_num|
        row.each_with_index do |element, column_num|
          widths[column_num] = [element.width, widths[column_num] || 0].max
          heights[row_num] = [element.height, heights[row_num] || 0].max
        end
      end

      # Actually place all the elements into the grid positions.
      total_height = padding_y
      @children.each_slice(num_columns).with_index do |row, row_num|
        total_width = padding_x

        row.each_with_index do |element, column_num|
          element.x = x + total_width
          total_width += widths[column_num]
          total_width += spacing_x unless column_num == num_columns - 1

          element.y = y + total_height
        end

        rect.width = total_width + padding_x if row_num == 0

        total_height += heights[row_num]
        total_height += spacing_y unless row_num == num_rows - 1
      end

      rect.height = total_height + padding_y

      nil
    end
  end
end