require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  def setup
    VerticalPacker.new(container) do |packer|
      label = Label.new(packer, text: "Label", tip: "I'm a label")

      Button.new(packer, text: "Button", tip: "I'm a button; press me!") do |button|
        button.subscribe :clicked_left_mouse_button do |sender, x, y|
          label.text = "Pressed the button!"
        end
      end

      ToggleButton.new(packer, text: "ToggleButton", tip: "I'm a button that toggles") do |button|
        button.subscribe :clicked_left_mouse_button do |sender, x, y|
          label.text = "Turned the toggle button #{sender.on? ? "on" : "off"}!"
        end
      end
    end
  end
end

ExampleWindow.new.show