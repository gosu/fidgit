require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label text: "Label", tip: "I'm a label"

      button text: "Button", tip: "I'm a button; press me!" do
        subscribe :clicked_left_mouse_button do |sender, x, y|
          my_label.text = "Pressed the button!"
        end
      end

      toggle_button text: "ToggleButton", tip: "I'm a button that toggles" do
        subscribe :clicked_left_mouse_button do |sender, x, y|
          my_label.text = "Turned the toggle button #{sender.on? ? "on" : "off"}!"
        end
      end
    end
  end
end

ExampleWindow.new.show