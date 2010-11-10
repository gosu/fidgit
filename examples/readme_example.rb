require_relative "../lib/fidgit"

# Normally, you'd load this from the gem.
# require 'fidgit'

class MyGame < Chingu::Window
  def initialize
    super(640, 480, false)
  end
  
  def setup
    push_game_state MyGuiState # To use Fidgit, a Fidgit::GuiState must be active.
  end
end

class MyGuiState < Fidgit::GuiState
  def initialize
    super

    pack :vertical do # Create a vertically packed section.
      my_label = label "Hello world!", background_color: Gosu::Color.rgb(0, 100, 0)
      
      button(text: "Goodbye") do
        my_label.text = "Goodbye cruel world!"
      end
    end
  end
end

MyGame.new.show