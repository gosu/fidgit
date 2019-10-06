module Fidgit
  # A basic scrolling area. It is not managed in any way (use ScrollWindow for that).
  class ScrollArea < Container
    # @return [Vertical] The content shown within this ScrollArea
    attr_reader :content

    def offset_x; x - @content.x; end
    def offset_y; y - @content.y; end

    def offset_x=(value)
      @content.x = x - [[@content.width - width, value].min, 0].max
    end

    def offset_y=(value)
      @content.y = y - [[@content.height - height, value].min, 0].max
    end

    # @option options [Number] :offset (0)
    # @option options [Number] :offset_x (value of :offset option)
    # @option options [Number] :offset_y (value of :offset option)
    # @option options [Element] :owner The owner of the content, such as the scroll-window containing the content.
    def initialize(options = {})
      options = {
        offset: 0,
        owner: nil,
      }.merge! options

      @owner = options[:owner]

      super(options)

      @content = Vertical.new(parent: self, padding: 0)

      self.offset_x = options[:offset_x] || options[:offset]
      self.offset_y = options[:offset_y] || options[:offset]
    end

    def hit_element(x, y)
      # Only pass on mouse events if they are inside the window.
      if hit?(x, y)
        @content.hit_element(x, y) || self
      else
        nil
      end
    end

    def recalc
      super
      # Always recalc our owner if our content resizes, even though our size can't change even if the content changes
      # (may encourage ScrollWindow to show/hide scroll-bars, for example)
      @owner.recalc if @owner
    end

    protected
    def draw_foreground
      $window.clip_to(*rect) do
        @content.draw
      end
    end

    protected
    def post_init_block(&block)
      with(&block)
    end
  end
end