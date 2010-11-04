require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    pack :vertical do
      initial_value = 10

      my_label = label "Slider handle is at #{initial_value}%"

      slider width: 100, range: 0..100, value: initial_value do |sender, value|
        my_label.text = "Slider handle is at #{value}%"
      end
    end
  end
end

ExampleWindow.new.show