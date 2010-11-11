# encoding: utf-8

require_relative 'composite'
require_relative 'scroll_area'

module Fidgit
  class ScrollWindow < Composite
    # @abstract
    class ScrollBar < Composite
      class Handle < Element
        handles :begin_drag
        handles :end_drag
        handles :update_drag

        def drag?(button); button == :left; end

        def initialize(options = {})
          super options

          subscribe :begin_drag do |sender, x, y|
            # Store position of the handle when it starts to drag.
            @drag_start_pos = [x - self.x, y - self.y]
          end

          subscribe :update_drag do |sender, x, y|
            parent.parent.handle_dragged_to x - @drag_start_pos[0], y - @drag_start_pos[1]
          end

          subscribe :end_drag do
            @drag_start_pos = nil
          end
        end
      end

      def initialize(options = {})
        options = {
          background_color: Gosu::Color.rgba(0, 0, 0, 0),
          border_color: Gosu::Color.rgba(0, 0, 0, 0),
          rail_width: 16,
          rail_color: Gosu::Color.rgb(50, 50, 50),
          handle_color: Gosu::Color.rgb(150, 0, 0),
          owner: nil,
        }.merge! options

        @owner = options[:owner]
        @rail_width = options[:rail_width]
        @rail_color = options[:rail_color]

        super options

        @handle_container = Container.new(parent: self, width: options[:width], height: options[:height]) do
          @handle = Handle.new(parent: self, x: x, y: y, background_color: options[:handle_color])
        end
      end
    end

    class HorizontalScrollBar < ScrollBar
      attr_reader :owner

      def initialize(options = {})
        super options

        @handle.height = height

        @handle_container.subscribe :left_mouse_button do |sender, x, y|
          distance = @owner.view_width
          @owner.offset_x += (x > @handle.x)? +distance : -distance
        end
      end

      def update
        window = parent.parent

        # Resize and re-locate the handles based on changes to the scroll-window.
        content_width = window.content_width.to_f
        @handle.width = (window.view_width * width) / content_width
        @handle.x = x + (window.offset_x * width) / content_width
      end

      def draw_foreground
        draw_rect x + padding_x, y + (height - @rail_width) / 2, width, @rail_width, z, @rail_color
        super
      end

      def handle_dragged_to(x, y)
        @owner.offset_x = @owner.content_width * ((x - self.x) / width.to_f)
      end
    end

    class VerticalScrollBar < ScrollBar
      def initialize(options = {})
        super options

        @handle.width = width

        @handle_container.subscribe :left_mouse_button do |sender, x, y|
          distance = @owner.view_height
          @owner.offset_y += (y > @handle.y)? +distance : -distance
        end
      end

      def update
        window = parent.parent
        content_height = window.content_height.to_f
        @handle.height = (window.view_height * height) / content_height
        @handle.y = y + (window.offset_y * height) / content_height
      end

      def draw_foreground
        draw_rect x + (width - @rail_width) / 2, y + padding_y, @rail_width, height, z, @rail_color
        super
      end

      def handle_dragged_to(x, y)
        @owner.offset_y = @owner.content_height * ((y - self.y) / height.to_f)
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

    def initialize(options = {})
      options = {
        scroll_bar_width: 16,
      }.merge! options

      super(options)

      @scroll_bar_width = options[:scroll_bar_width]

      @grid = pack :grid, num_columns: 2, padding: 0, spacing: 0 do
        @view = scroll_area(owner: self, width: options[:width], height: options[:height])
        @spacer = label '', padding: 0, width: 0, height: 0
      end

      @scroll_bar_v = VerticalScrollBar.new(owner: self, width: @scroll_bar_width, height: options[:height])
      @scroll_bar_h = HorizontalScrollBar.new(owner: self, width: options[:width], height: @scroll_bar_width)
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