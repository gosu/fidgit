# encoding: utf-8

require_relative 'container'

module Fidgit
  # A basic scrolling area. It is not managed in any way (use ScrollWindow for that).
  class ScrollArea < Container
    # @return [VerticalPacker] The content shown within this ScrollArea
    attr_reader :content

    # Offset of the content within this ScrollArea.
    attr_reader :offset_x, :offset_y

    def x=(value); @rect.x = value; end
    def y=(value); @rect.y = value; end

    def offset_x=(value)
      @offset_x = [[@content.width - width, value].min, 0].max
    end

    def offset_y=(value)
      @offset_y = [[@content.height - height, value].min, 0].max
    end

    # @option options [Number] :offset (0)
    # @option options [Number] :offset_x (value of :offset option)
    # @option options [Number] :offset_y (value of :offset option)
    # @option options [Element] :owner The owner of the content, such as the scroll-window containing the content.
    def initialize(parent, options = {})
      options = {
        offset: 0,
        owner: nil,
      }.merge! options

      @owner = options[:owner]
      @offset_x = options[:offset_x] || options[:offset]
      @offset_y = options[:offset_y] || options[:offset]

      super(parent, options)

      @content = VerticalPacker.new(self, padding: 0)
    end

    def recalc
      super
      # Always recalc our owner if our content resizes, even though our size can't change even if the content changes
      # (may encourage ScrollWindow to show/hide scroll-bars, for example)
      @owner.recalc if @owner
    end

    def hit_object?(x, y)
      @content.hit_object(x - @offset_x, y - @offset_y)
    end

    protected
    def draw_foreground
      $window.clip_to(*rect) do
        $window.translate(x - @offset_x, y - @offset_y) do
          @content.draw
        end
      end
    end

    protected
    def post_init_block(&block)
      @content.instance_methods_eval &block
    end
  end
end