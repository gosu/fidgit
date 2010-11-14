# encoding: utf-8

require_relative 'composite'
require_relative 'scroll_area'
require_relative 'scroll_bar'

module Fidgit
  class ScrollWindow < Composite
	  def content; @view.content; end
	
    def offset_x; @view.offset_x; end
    def offset_x=(value); @view.offset_x = value; end
    def offset_y; @view.offset_y; end
    def offset_y=(value); @view.offset_y = value; end

    def view_width; @view.width; end
    def view_height; @view.height; end
    def content_width; @view.content.width; end
    def content_height; @view.content.height; end
	
	def width=(value); super(value); end
	def height=(value); super(value); end

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

      @scroll_bar_v = VerticalScrollBar.new(owner: self, width: @scroll_bar_width, align_v: :fill)
      @scroll_bar_h = HorizontalScrollBar.new(owner: self, height: @scroll_bar_width, align_h: :fill)
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
            @grid.remove @spacer
            @grid.insert 1, @scroll_bar_v
          end
        else
          if @scroll_bar_v.parent
            @view.send(:rect).width += @scroll_bar_v.width
            @grid.remove @scroll_bar_v
            @grid.insert 1, @spacer
          end
        end

        if content_width > view_width
          unless @scroll_bar_h.parent
            @view.send(:rect).height -= @scroll_bar_h.height
            @grid.add @scroll_bar_h
          end
        else
          if @scroll_bar_h.parent
            @view.send(:rect).height += @scroll_bar_h.height
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