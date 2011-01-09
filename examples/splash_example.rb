require_relative 'helpers/example_window'

# By using a splash screen of some sort, one can switch to another resolution for the main game.
class ExampleState < GuiState
  def initialize
    super
    pack :vertical do
      pack :horizontal do
        text = label "Width:"

        @width_combo = combo_box(value: [640, 480]) do
          [[640, 480], [800, 600], [Gosu::screen_width, Gosu::screen_height]].each do |width, height|
            item "#{width}x#{height}", [width, height]
          end
        end
      end

      @full_screen_button = toggle_button "Fullscreen?"

      button "Load game", icon: Gosu::Image["head_icon.png"] do
        $window.close
        window = Chingu::Window.new(*@width_combo.value, @full_screen_button.value)
        window.push_game_state ExampleAfterState
        window.show
      end
    end
  end
end

class ExampleAfterState < GuiState
  def initialize
    super

    on_input(:esc, :exit)

    pack :vertical do
      label "Game loaded!", icon: Gosu::Image["head_icon.png"], border_color: Gosu::Color.rgb(255, 255, 255)
    end
  end
end

ExampleWindow.new.show