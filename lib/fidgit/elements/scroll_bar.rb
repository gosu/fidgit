# encoding: utf-8

require_relative 'composite'

module Fidgit
  # @abstract
  class ScrollBar < Composite
    class Handle < Element
      event :begin_drag
      event :update_drag
      event :end_drag

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
        background_color: default(:background_color),
        border_color: default(:border_color),
        rail_width: default(:rail_width),
        rail_color: default(:rail_color),
        handle_color: default(:handle_color),
        owner: nil,
      }.merge! options

      @owner = options[:owner]
      @rail_thickness = options[:rail_width]
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
      draw_rect x + padding_left, y + (height - @rail_thickness) / 2, width, @rail_thickness, z, @rail_color
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
      draw_rect x + (width - @rail_thickness) / 2, y + padding_top, @rail_thickness, height, z, @rail_color
      super
    end

    def handle_dragged_to(x, y)
      @owner.offset_y = @owner.content_height * ((y - self.y) / height.to_f)
    end
  end
end