require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical do
      my_label = label "Label", tip: "I'm a label"

      buttons = []

      # A plain button, with some text on it.
      buttons << button("Button", tip: "I'm a button; press me!", shortcut: :auto) do
        my_label.text = "Pressed the button!"
      end

      # Buttons with icons in each possible positions.
      [:left, :right, :top, :bottom].each do |position|
        buttons << button("Icon at #{position}", icon: Gosu::Image["head_icon.png"], icon_position: position, icon_options: { factor: 2 }, tip: "I'm a button; press me!", shortcut: :auto) do
          my_label.text = "Pressed the button (icon to #{position})!"
        end
      end

      # A toggling button.
      buttons << toggle_button("ToggleButton", tip: "I'm a button that toggles", shortcut: :o) do |sender, value|
        my_label.text = "Turned the toggle button #{value ? "on" : "off"}!"
      end

      # A toggle-button that controls whether all the other buttons are enabled.
      toggle_button("Enable other two buttons", value: true) do |sender, value|
        buttons.each {|button| button.enabled = value }
      end
    end
  end
end

ExampleWindow.new.show