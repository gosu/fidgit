require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "Slider handle is at ?"

      slider width: 100, range: 0..100, value: 10 do
        subscribe :changed do |sender, value|
          my_label.text = "Slider handle is at #{value}%"
        end

        my_label.text = "Slider handle is at #{value}%"
      end
    end
  end
end

ExampleWindow.new.show