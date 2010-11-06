# encoding: utf-8

require_relative 'composite'
require_relative 'button'

module Fidgit
  class MenuPane < Composite
    # An item within the menu.
    class Item < Button
      DEFAULT_BORDER_COLOR = Gosu::Color.rgba(0, 0, 0, 0)
      attr_reader :value, :shortcut

      # @param (see Button#initialize)
      #
      # @option (see Button#initialize)
      # @param [any] value Value if the user picks this item
      # @option options [Boolean] :enabled (true)
      # @option options [String] :shortcut ('')
      def initialize(parent, value, options = {})
        options = {
          enabled: true,
          border_color: DEFAULT_BORDER_COLOR,
        }.merge! options

        @value = value
        @enabled = [true, false].include?(options[:enabled]) ? options[:enabled] : true
        @shortcut = options[:shortcut] || ''

        super(parent, options)
      end

      def draw_foreground
        super
        unless @shortcut.empty?
          font.draw_rel("#{@shortcut}", rect.right - padding_x, y + ((height - font_size) / 2).floor, z, 1, 0, 1, 1, color)
        end

        nil
      end

      protected
      def layout
        super
        rect.width += font.text_width("  #{@shortcut}") unless @shortcut.empty?
        nil
      end
    end

    class Separator < Item
      DEFAULT_LINE_HEIGHT = 2

      # @param (see Item#initialize)
      #
      # @option (see Item#initialize)
      def initialize(parent, options = {})
        options = {
          enabled: false,
          line_height: DEFAULT_LINE_HEIGHT,
        }.merge! options

        @line_height = options[:line_height]

        super parent, options
      end

      protected
      def layout
        super
        rect.height = @line_height
        nil
      end
    end

    handles :selected

    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(50, 50, 50)

    def index(value); @items.index find(value); end
    def size; @items.size; end
    def [](index); @items[index]; end

    # @option (see Composite#initialize)
    # @option options [Float] :x (Left side of cursor, if in a GuiState)
    # @option options [Float] :y (Bottom of cursor, if in a GuiState)
    # @option options [Boolean] :show (true) Whether to show immediately (show later with #show).
    def initialize(options = {}, &block)
      options = {
        background_color: DEFAULT_BACKGROUND_COLOR.dup,
        z: Float::INFINITY,
        show: true,
      }.merge! options

      state = $window.current_game_state
      if state.is_a? GuiState
        cursor = $window.current_game_state.cursor
        options = {
          x: cursor.x,
          y: cursor.y + cursor.height,
        }.merge! options
      end

      super(nil, options)

      @items = pack :vertical, spacing: 0, padding: 0

      if options[:show] and state.is_a? GuiState
        show
      end
    end

    def find(value)
      @items.find {|c| c.value == value }
    end

    def separator(options = {})
      options[:z] = z

      Separator.new(@items, options)
    end

    def item(value, options = {}, &block)
      options[:z] = z
      item = Item.new(@items, value, options, &block)

      item.subscribe :left_mouse_button, method(:item_selected)
      item.subscribe :right_mouse_button, method(:item_selected)

      item
    end

    def item_selected(sender, x, y)
      publish(:selected, sender.value)

      $window.game_state_manager.current_game_state.hide_menu

      nil
    end

    def show
      $window.game_state_manager.current_game_state.show_menu self
      nil
    end

    protected
    def layout
      super

      if @items
        # Ensure the menu can't go over the edge of the screen. If it can't be avoided, align with left edge of screen.
        rect.x = [[x, $window.width - width - padding_x].min, 0].max
        rect.y = [[y, $window.height - height - padding_y].min, 0].max

        # Move the actual list if the menu has moved to keep on the screen.
        @items.x = x + padding_x
        @items.y = y + padding_y

        # Ensure that all items are of the same width.
        max_width = @items.each.to_a.map {|c| c.width }.max || 0
        @items.each {|c| c.rect.width = max_width }
      end

      nil
    end
  end
end