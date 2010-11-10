# encoding: utf-8

require_relative 'composite'
require_relative 'scroll_area'

module Fidgit
  class ScrollWindow < Composite
    # @abstract
    class ScrollBar < Composite
      class Handle < Element
      end

      def initialize(parent, options = {})
        options = {
          background_color: Gosu::Color.rgb(50, 50, 50),
          border_color: Gosu::Color.rgb(100, 100, 100),
          handle_color: Gosu::Color.rgb(150, 0, 0)
        }.merge! options

        super parent, options

        Container.new(self, width: options[:width], height: options[:height]) do
          @handle = Handle.new(self, x: x, y: y, background_color: options[:handle_color])
        end
      end
    end

    class HorizontalScrollBar < ScrollBar
      def initialize(parent, options = {})
        super parent, options

        @handle.height = height
      end

      def update
        window = parent.parent

        # Resize and re-locate the handles based on changes to the scroll-window.
        content_width = window.content_width.to_f
        @handle.width = (window.view_width * width) / content_width
        @handle.x = x + (window.offset_x * width) / content_width
      end
    end

    class VerticalScrollBar < ScrollBar
      def initialize(parent, options = {})
        super parent, options

        @handle.width = width
      end

      def update
        window = parent.parent
        content_height = window.content_height.to_f
        @handle.height = (window.view_height * height) / content_height
        @handle.y = y + (window.offset_y * height) / content_height
      end
    end

    def offset_x; @view.offset_x; end
    def offset_x=(value); @view.offset_x = value; end
    def offset_y; @view.offset_y; end
    def offset_y=(value); @view.offset_y = value; end

    def view_width; @view.width; end
    def view_height; @view.height; end
    def content_width; @view.content.width; end
    def content_height; @view.content.height; end

    def initialize(parent, options = {})
      options = {
        scroll_bar_width: 15,
      }.merge! options

      super(parent, options)

      @scroll_bar_width = options[:scroll_bar_width]

      @grid = pack :grid, num_columns: 2, padding: 0, spacing: 0 do
        @view = scroll_area(owner: self, width: options[:width], height: options[:height])
        @spacer = label '', padding: 0, width: 0, height: 0
      end

      @scroll_bar_v = VerticalScrollBar.new(nil, width: @scroll_bar_width, height: options[:height])
      @scroll_bar_h = HorizontalScrollBar.new(nil, width: options[:width], height: @scroll_bar_width)
    end

    protected
    def layout
      # Prevent recursive layouts.
      return if @in_layout

      @in_layout = true

      if @view
        # Constrain the values of the offsets.
        @view.offset_x = @view.offset_x
        @view.offset_y = @view.offset_y

        if content_height > view_height
          unless @scroll_bar_v.parent
            @view.send(:rect).width -= @scroll_bar_v.width
            @scroll_bar_h.send(:rect).width -= @scroll_bar_v.width
            @grid.remove @spacer
            @grid.insert 1, @scroll_bar_v
          end
        else
          if @scroll_bar_v.parent
            @view.send(:rect).width += @scroll_bar_v.width
            @scroll_bar_h.send(:rect).width += @scroll_bar_v.width
            @grid.remove @scroll_bar_v
            @grid.insert 1, @spacer
          end
        end

        if content_width > view_width
          unless @scroll_bar_h.parent
            @view.send(:rect).height -= @scroll_bar_h.height
            @scroll_bar_v.send(:rect).height -= @scroll_bar_h.height
            @grid.add @scroll_bar_h
          end
        else
          if @scroll_bar_h.parent
            @view.send(:rect).height += @scroll_bar_h.height
            @scroll_bar_v.send(:rect).height += @scroll_bar_h.height
            @grid.remove @scroll_bar_h
          end
        end
      end

      super

      @in_layout = false
    end

    protected
    def post_init_block(&block)
      @view.content.instance_methods_eval &block
    end
  end
end