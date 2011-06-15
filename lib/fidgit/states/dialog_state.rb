module Fidgit
  # A modal dialog.
  # @abstract
  class DialogState < GuiState
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(75, 75, 75)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgb(255, 255, 255)

    DEFAULT_SHADOW_COLOR = Gosu::Color.rgba(0, 0, 0, 100)
    DEFAULT_SHADOW_OFFSET = 8

    def initialize(options = {})
      # @option options [Gosu::Color] :shadow_color (transparent black) Color of the shadow.
      # @option options [Gosu::Color] :shadow_offset (8) Distance shadow is offset to bottom and left.
      # @option options [Gosu::Color] :shadow_full (false) Shadow fills whole screen. Ignores :shadow_offset option if true.
      options = {
        shadow_color: DEFAULT_SHADOW_COLOR,
        shadow_offset: DEFAULT_SHADOW_OFFSET,
        shadow_full: false,
      }.merge! options

      @shadow_color = options[:shadow_color].dup
      @shadow_offset = options[:shadow_offset]
      @shadow_full = options[:shadow_full]

      super()
    end

    def draw
      $window.game_state_manager.previous_game_state.draw # Keep the underlying state being shown.
      $window.flush

      if @shadow_full
        draw_rect 0, 0, $window.width, $window.height, -Float::INFINITY, @shadow_color
      elsif @shadow_offset > 0
        dialog = container[0]
        draw_rect dialog.x + @shadow_offset, dialog.y + @shadow_offset, dialog.width, dialog.height, -Float::INFINITY, @shadow_color
      end

      super
    end

    def show
      $window.game_state_manager.push(self, finalize: false) unless $window.game_state_manager.game_states.include? self
      nil
    end

    def hide
      $window.game_state_manager.pop(setup: false) if $window.game_state_manager.current == self
      nil
    end
  end
end