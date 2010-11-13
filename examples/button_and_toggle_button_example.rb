require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "Label", tip: "I'm a label"

      button("Button", tip: "I'm a button; press me!") do
        my_label.text = "Pressed the button!"
      end

      toggle_button("ToggleButton", tip: "I'm a button that toggles") do |sender, value|
        my_label.text = "Turned the toggle button #{value ? "on" : "off"}!"
      end
    end
  end
end

ExampleWindow.new.show