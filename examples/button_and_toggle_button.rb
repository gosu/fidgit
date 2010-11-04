require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "Label", tip: "I'm a label"

      button text: "Button", tip: "I'm a button; press me!" do
        my_label.text = "Pressed the button!"
      end

      toggle_button text: "ToggleButton", tip: "I'm a button that toggles" do |sender, x, y|
        my_label.text = "Turned the toggle button #{sender.on? ? "on" : "off"}!"
      end
    end
  end
end

ExampleWindow.new.show