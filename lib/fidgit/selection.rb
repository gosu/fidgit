module Fidgit
  class Selection
    MIN_DRAG_DISTANCE = 2

    def size; @items.size; end
    def empty?; @items.empty?; end
    def [](index); @items[index]; end
    def each(&block); @items.each(&block); end
    def to_a; @items.dup; end
    def include?(object); @items.include? object; end

    # Current being dragged?
    def dragging?; @dragging; end

    # Actually moved during a dragging operation?
    def moved?; @moved; end

    def initialize
      @items = []
      @moved = false
      @dragging = false
    end

    def add(object)
      object.selected = true
      @items.push(object)

      self
    end

    def remove(object)
      @items.delete(object)
      object.selected = false
      object.dragging = false

      self
    end

    def clear
      end_drag if dragging?
      @items.each { |o| o.selected = false; o.dragging = false }
      @items.clear

      self
    end

    def begin_drag(x, y)
      @initial_x, @initial_y = x, y
      @last_x, @last_y = x, y
      @dragging = true
      @moved = false

      self
    end

    def end_drag
      @items.each do |object|
        object.x, object.y = object.x.round, object.y.round
        object.dragging = false
      end
      @dragging = false
      @moved = false

      self
    end

    # Move all dragged object back to original positions.
    def reset_drag
      if moved?
        @items.each do |o|
          o.x += @initial_x - @last_x
          o.y += @initial_y - @last_y
        end
      end

      self.end_drag

      self
    end

    def update_drag(x, y)
      x, y = x.round, y.round

      # If the mouse has been dragged far enough from the initial click position, then 'pick up' the objects and drag.
      unless moved?
        if distance(@initial_x, @initial_y, x, y) > MIN_DRAG_DISTANCE
          @items.each { |o| o.dragging = true }
          @moved = true
        end
      end

      if moved?
        @items.each do |o|
          o.x += x - @last_x
          o.y += y - @last_y
        end

        @last_x, @last_y = x, y
      end

      self
    end
  end
end