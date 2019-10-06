module Fidgit
  class Cursor < Chingu::GameObject
    ARROW = 'arrow.png'
    HAND = 'hand.png'

    def initialize(options = {})
      options = {
        image: Gosu::Image[ARROW],
        rotation_center: :top_left,
        zorder: Float::INFINITY
      }.merge!(options)

      super(options)

      nil
    end

    # Is the mouse pointer position inside the game window pane?
    def inside_window?
      x >= 0 and y >= 0 and x < $window.width and y < $window.height
    end

    def update
      self.x, self.y = $window.mouse_x, $window.mouse_y

      super

      nil
    end

    def draw
      # Prevent system and game mouse from being shown at the same time.
      super if inside_window? and $window.current_game_state.is_a? GuiState and not $window.needs_cursor?
    end
  end
end