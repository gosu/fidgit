# encoding: utf-8

module Fidgit
  class Button < Label
    # @param (see Label#initialize)
    # @option (see Label#initialize)
    # @option options [Symbol] :shortcut (nil) Adds a shortcut key for this element, that activates it. :auto takes the first letter of the text.
    def initialize(text, options = {}, &block)
      options = {
        color: default(:color),
        background_color: default(:background_color),
        border_color: default(:border_color),
        shortcut_color: default(:shortcut_color),
        shortcut: nil,
      }.merge! options

      @shortcut_color = options[:shortcut_color].dup

      @shortcut = if options[:shortcut] == :auto
                    raise ArgumentError.new("Can't use :auto for :shortcut without text") if text.empty?
                    text[0].downcase.to_sym
                  else
                    options[:shortcut]
                  end

      raise ArgumentError.new(":shortcut must be a symbol") unless @shortcut.nil? or @shortcut.is_a? Symbol

      super(text, options)

      self.text = text # Force shortcut to be written out properly.

      update_colors
    end

    def text=(value)
      if @shortcut
        super value.sub(/#{@shortcut}/i) {|char| "<c=#{@shortcut_color.to_hex}>#{char}</c>" }
      else
        super value
      end
    end

    def parent=(value)
      if @shortcut
        state = $window.game_state_manager.inside_state || $window.current_game_state
        if parent
          raise ArgumentError.new("Repeat of shortcut #{@shortcut.inspect}") if state.input.has_key? @shortcut
          state.on_input(@shortcut) { activate unless state.focus }
        else
          state.input.delete @shortcut
        end
      end

      super(value)
    end

    def clicked_left_mouse_button(sender, x, y)
      # TODO: Play click sound?
      nil
    end

    def enabled=(value)
      super(value)
      update_colors

      value
    end

    def enter(sender)
      @mouse_over = true
      update_colors

      nil
    end

    def leave(sender)
      @mouse_over = false
      update_colors

      nil
    end

    protected
    def update_colors
      @background_color = if @mouse_over and enabled?
        default(:hover, :background_color)
      else
        default(:background_color)
      end

      self.color = if enabled?
        default(:color)
      else
        default(:disabled, :color)
      end

      @icon.enabled = enabled? if @icon

      nil
    end

    protected
    # A block added to any button subscribes to LMB click.
    def post_init_block(&block)
      subscribe :clicked_left_mouse_button, &block
    end

    public
    # Activate the button, as though it had been clicked on.
    # Does not do anything if the button is disabled.
    def activate
      publish(:clicked_left_mouse_button, x + width / 2, y + height / 2) if enabled?
    end
  end
end