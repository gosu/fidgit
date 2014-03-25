require 'forwardable'

module Fidgit
  class MenuPane < Composite
    # An item within the menu.
    class Item < Button
      attr_reader :value, :shortcut_text

      # @param (see Button#initialize)
      #
      # @option (see Button#initialize)
      # @param [any] value Value if the user picks this item
      # @option options [String] :shortcut_text ('')
      def initialize(text, value, options = {})
        options = {
          enabled: true,
          border_color: default(:border_color),
          shortcut_text: '',
        }.merge! options

        @value = value
        @shortcut_text = options[:shortcut_text]

        super(text, options)
      end

      def draw_foreground
        super

        unless @shortcut_text.empty?
          font.draw_rel("#{@shortcut_text}", rect.right - padding_right, y + ((height - font.height) / 2).floor, z, 1, 0, 1, 1, color)
        end

        nil
      end

      protected
      def layout
        super

        # Ignore layout request when asked before TextLine has been created.
        rect.width += font.text_width("  #{@shortcut_text}") unless @shortcut_text.empty? or @text.nil?

        nil
      end
    end

    class Separator < Label
      # @param (see Item#initialize)
      #
      # @option (see Item#initialize)
      def initialize(options = {})
        options = {
          height: default(:line_height),
          background_color: default(:background_color),
          padding: 0,
        }.merge! options

        super '', options
      end
    end

    extend Forwardable

    def_delegators :@items, :each, :clear, :size, :[]

    event :selected

    def index(value); @items.index find(value); end
    def x=(value); super(value); recalc; end
    def y=(value); super(value); recalc; end

    # @option (see Composite#initialize)
    # @option options [Float] :x (cursor x, if in a GuiState)
    # @option options [Float] :y (cursor y, if in a GuiState)
    # @option options [Boolean] :show (true) Whether to show immediately (show later with #show).
    def initialize(options = {}, &block)
      options = {
        background_color: default(:color),
        z: Float::INFINITY,
        show: true,
      }.merge! options

      state = $window.current_game_state
      if state.is_a? GuiState
        cursor = $window.current_game_state.cursor
        options = {
          x: cursor.x,
          y: cursor.y,
        }.merge! options
      end

      @items = nil

      super(options)

      @items = vertical spacing: 0, padding: 0

      if options[:show] and state.is_a? GuiState
        show
      end
    end

    def find(value)
      @items.find {|c| c.value == value }
    end

    def separator(options = {})
      options[:z] = z

      Separator.new({ parent: @items }.merge!(options))
    end

    def item(text, value, options = {}, &block)
      options = options.merge({
         parent: @items,
         z: z,
      })
      item = Item.new(text, value, options, &block)

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
        # Ensure the menu can't go over the edge of the screen. If it can't be avoided, align with top-left edge of screen.
        rect.x = [[x, $window.width - width - padding_right].min, 0].max
        rect.y = [[y, $window.height - height - padding_bottom].min, 0].max

        # Move the actual list if the menu has moved to keep on the screen.
        @items.x = x + padding_left
        @items.y = y + padding_top

        # Ensure that all items are of the same width.
        max_width = @items.map(&:width).max || 0
        @items.each {|c| c.rect.width = max_width }

        @items.recalc # Move all the items inside the packer to correct ones.
      end

      nil
    end
  end
end