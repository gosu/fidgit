require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical do
      my_label = label "Label", tip: "I'm a label"

      combo_box(value: 1, tip: "I'm a combo box; press me and make a selection!") do
        subscribe :changed do |sender, value|
          my_label.text = "Chose #{value}!"
        end

        item "One", 1
        item "Two", 2
        item "Three", 3
      end
    end
  end
end

ExampleWindow.new.show