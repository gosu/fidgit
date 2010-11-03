require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "Label", tip: "I'm a label"

      combo_box(value: 1, tip: "I'm a combo box; press me and make a selection!") do
        subscribe :changed do |sender, value|
          my_label.text = "Chose #{value}!"
        end

        item 1, text: "One"
        item 2, text: "Two"
        item 3, text: "Three"
      end
    end
  end
end

ExampleWindow.new.show