# encoding: utf-8

require_relative 'packer'

module Fidgit
  # A vertically aligned element packing container.

  class GridPacker < Packer
    DEFAULT_CELL_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
    DEFAULT_CELL_BACKGROUND_COLOR = Gosu::Color.rgba(0, 0, 0, 0)

    # @return [Integer]
    attr_reader :num_rows
    # @return [Integer]
    attr_reader :num_columns

    # @note Currently only supports +num_columns+ mode (not +num_rows+).
    #
    # @param (see Packer#initialize)
    #
    # @option (see Packer#initialize)
    # @option options [Integer] :num_columns Maximum number of columns to use (incompatible with :num_rows)
    # @option options [Integer] :num_rows Maximum number of rows to use (incompatible with :num_columns)
    def initialize(options = {})
      options = {
        cell_border_color: DEFAULT_CELL_BORDER_COLOR,
        cell_background_color: DEFAULT_CELL_BACKGROUND_COLOR,
      }.merge! options

      @num_columns = options[:num_columns]
      @num_rows = options[:num_rows]
      raise ArgumentError, "options :num_rows and :num_columns are not compatible" if @num_rows and @num_columns

      @cell_border_color = options[:cell_border_color].dup
      @cell_background_color = options[:cell_background_color].dup

      @type = @num_rows ? :fixed_rows : :fixed_columns

      super options
    end

    protected
    def layout
      rearrange
      repack
    end

    protected
    # Rearrange the cells based on changes to the number of rows/columns or adding/removing elements.
    def rearrange
      # Calculate the number of the dynamic dimension.
      case @type
      when :fixed_rows
        @num_columns = (size / @num_rows.to_f).ceil
      when :fixed_columns
        @num_rows = (size / @num_columns.to_f).ceil
      end

      # Create an array containing all the rows.
      @rows = case @type
      when :fixed_rows
        # Rearrange the list, arranged by columns, into rows.
        rows = Array.new(@num_rows) { [] }
        @children.each_with_index do |child, i|
          rows[i % @num_rows].push child
        end
        rows
      when :fixed_columns
        @children.each_slice(@num_columns).to_a
      end

      nil
    end

    protected
    # Repack all the elements into their positions.
    def repack
      @widths = Array.new(@num_columns, 0)
      @heights = Array.new(@num_rows, 0)

      # Calculate the maximum widths of each column and the maximum height of each row.
      @rows.each_with_index do |row, row_num|
        row.each_with_index do |element, column_num|
          @widths[column_num] = [element.width, @widths[column_num] || 0].max || 0
          @heights[row_num] = [element.height, @heights[row_num] || 0].max || 0
        end
      end

      # Expand the size of the rightmost column to the minimum size required.
      if @num_columns > 0
        total_width = @widths.inject(0, :+) + (padding_x * 2) + ((@num_columns - 1) * spacing_x)
        if total_width < min_width
          @widths[@num_columns - 1] += min_width - total_width
        end
      end

      # Expand the size of the bottommost column to the minimum size required.
      if @num_rows > 0
        total_height = @heights.inject(0, :+) + (padding_y * 2) + ((@num_rows - 1) * spacing_y)
        if total_height < min_height
          @heights[@num_rows - 1] += min_height - total_height
        end
      end

      # Actually place all the elements into the grid positions, modified by valign and align.
      current_y = y + padding_y
      @rows.each_with_index do |row, row_num|
        current_x = x + padding_x

        row.each_with_index do |element, column_num|
          element.x = current_x

          case element.align_h # Take horizontal alignment into consideration.
            when :fill
              if element.width < @widths[column_num]
                element.width = @widths[column_num]
                element.send :repack if element.is_a? GridPacker
              end
            when :center
              element.x += (@widths[column_num] - element.width) / 2
            when :right
              element.x += @widths[column_num] - element.width
          end

          current_x += @widths[column_num]
          current_x += spacing_x unless column_num == @num_columns - 1

          element.y = current_y

          case element.align_v # Take horizontal alignment into consideration.
            when :fill
              if element.height < @heights[row_num]
                element.height = @heights[row_num]
                element.send :repack if element.is_a? GridPacker
              end
            when :center
              element.y += (@heights[row_num] - element.height) / 2
            when :bottom
              element.y += @heights[row_num] - element.height
            else
          end
        end

        self.width = current_x - x + padding_x if row_num == 0

        current_y += @heights[row_num] unless row.empty?
        current_y += spacing_y unless row_num == num_rows - 1
      end

      self.height = current_y - y + padding_y

      nil
    end

    protected
    # @yield The rectangle of each cell within the grid.
    # @yieldparam [Number] x
    # @yieldparam [Number] y
    # @yieldparam [Number] width
    # @yieldparam [Number] height
    def each_cell_rect
      x = self.x + padding_x

      @widths.each_with_index do |width, column_num|
        y = self.y + padding_y

        @heights.each_with_index do |height, row_num|
          yield x, y, width, height if @rows[row_num][column_num]
          y += height + spacing_y
        end

        x += width + spacing_x
      end

      nil
    end

    protected
    def draw_background
      super

      # Draw the cell backgrounds.
      unless @cell_background_color.transparent?
        each_cell_rect do |x, y, width, height|
          draw_rect x, y, width, height, z, @cell_background_color
        end
      end

      nil
    end

    protected
    def draw_border
      super

      # Draw the cell borders.
      unless @cell_border_color.transparent?
        each_cell_rect do |x, y, width, height|
          draw_frame x, y, width, height, z, @cell_border_color
        end
      end

      nil
    end
  end
end