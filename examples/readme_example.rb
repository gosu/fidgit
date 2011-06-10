require_relative "../lib/fidgit"

# Normally, you'd load this from the gem using:
#   require 'fidgit'

class MyGame < Chingu::Window
  def initialize
    super(640, 480, false)

    # To use the Fidgit features, a Fidgit::GuiState must be active.
    push_game_state MyGuiState
  end
end

class MyGuiState < Fidgit::GuiState
  def initialize
    super

    # Create a vertically packed section, centred on the window.
    vertical align: :center do
      # Create a label with a dark green background.
      my_label = label "Hello world!", background_color: Gosu::Color.rgb(0, 100, 0)

      # Create a button that, when clicked, changes the label text.
      button("Goodbye", align_h: :center, tip: "Press me and be done with it!") do
        my_label.text = "Goodbye cruel world!"
      end
    end
  end
end

MyGame.new.show