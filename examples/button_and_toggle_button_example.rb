require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical do
      my_label = label "Label", tip: "I'm a label"

      my_button = button("Button", tip: "I'm a button; press me!", shortcut: :auto) do
        my_label.text = "Pressed the button!"
      end

      my_toggle_button = toggle_button("ToggleButton", tip: "I'm a button that toggles", shortcut: :t) do |sender, value|
        my_label.text = "Turned the toggle button #{value ? "on" : "off"}!"
      end

      toggle_button("Enable other two buttons", value: true) do |sender, value|
        my_button.enabled = value
        my_toggle_button.enabled = value
      end
    end
  end
end

ExampleWindow.new.show