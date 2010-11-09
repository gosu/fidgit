# encoding: utf-8

require_relative 'composite'

module Fidgit
  class ScrollWindow < Composite
    class ScrollBar < Composite
      class Handle < Element
      end

      VALID_TYPES = [:horizontal, :vertical]

      def initialize(parent, type, options = {})
        options = {
          background_color: Gosu::Color.rgb(50, 50, 50),
          border_color: Gosu::Color.rgb(100, 100, 100),
          handle_color: Gosu::Color.rgb(150, 0, 0)
        }.merge! options

        @type = type

        super parent, options

        Container.new(self, width: options[:width], height: options[:height]) do
          @handle = case @type
          when :horizontal
            Handle.new(self, x: x, y: y, height: height, background_color: options[:handle_color])
          when :vertical
            Handle.new(self, x: x, y: y, width: width, background_color: options[:handle_color])
          end
        end
      end

      def update
        window = parent.parent

        # Resize and re-locate the handles based on changes to the scroll-window.
        case @type
        when :horizontal
          content_width = window.content_width.to_f
          @handle.width = (window.view_width * width) / content_width
          @handle.x = x + (window.offset_x * width) / content_width
        when :vertical
          content_height = window.content_height.to_f
          @handle.height = (window.view_height * height) / content_height
          @handle.y = y + (window.offset_y * height) / content_height
        end

        nil
      end
    end

    attr_reader :content
    attr_reader :offset_x, :offset_y

    def offset_x=(value)
      @offset_x = [[@content.width - @view.width, value].min, 0].max
    end

    def offset_y=(value)
      @offset_y = [[@content.height - @view.height, value].min, 0].max
    end

    def view_width; @view.width; end
    def view_height; @view.height; end
    def content_width; @content.width; end
    def content_height; @content.height; end

    def initialize(parent, options = {})
      options = {
        offset: 0,
        scroll_bar_width: 15,
      }.merge! options

      @offset_x = options[:offset_x] || options[:offset]
      @offset_y = options[:offset_y] || options[:offset]

      super(parent, options)

      @content = VerticalPacker.new(nil, padding: 0)

      @scroll_bar_width = options[:scroll_bar_width]

      @grid = pack :grid, num_columns: 2, padding: 0, spacing: 0 do
        @view = label "", padding: 0, width: options[:width], height: options[:height]
        @view.subscribe :left_mouse_button do |sender, x, y|
          @content.publish :left_mouse_button, @content, x + @offset_x, y + @offset_y
        end
        @spacer = label '', padding: 0, width: 0, height: 0
      end

      @scroll_bar_v = ScrollBar.new(nil, :vertical, width: @scroll_bar_width, height: options[:height])
      @scroll_bar_h = ScrollBar.new(nil, :horizontal, width: options[:width], height: @scroll_bar_width)
    end

    def update
      @content.update
      super
      recalc
      nil
    end

    protected
    def layout
      # Prevent recursive layouts.
      return if @in_layout

      @in_layout = true

      if @content and @view
        # Constrain the values of the offsets.
        self.offset_x = offset_x
        self.offset_y = offset_y

        if @content.height > height
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

        if @content.width > width
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
    def draw_foreground
      super

      $window.clip_to(*@view.send(:rect)) do
        $window.translate(x - @offset_x, y - @offset_y) do
          # Todo: Only draw components displayed.
          @content.draw
        end
      end

      nil
    end

    protected
    def post_init_block(&block)
      @content.instance_methods_eval &block
    end
  end
end