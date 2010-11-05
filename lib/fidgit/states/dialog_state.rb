require_relative 'gui_state'

module Fidgit
  # A modal dialog.
  # @abstract
  class DialogState < GuiState
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(200, 200, 200)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgb(255, 255, 255)

    def draw
      $window.game_state_manager.previous_game_state.draw # Keep the underlying state being shown.

      super
    end

    def show
      $window.game_state_manager.push_game_state self, finalize: false
      nil
    end

    def hide
      $window.game_state_manager.pop_game_state(setup: false)
      nil
    end
  end
end