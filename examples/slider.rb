require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    VerticalPacker.new(container) do |packer|
      label = Label.new(packer, text: "Slider handle is at ?")

      Slider.new(packer, width: 100, range: 0..100, value: 10) do |slider|
        slider.subscribe :changed do |sender, value|
          label.text = "Slider handle is at #{value}%"
        end

        label.text = "Slider handle is at #{slider.value}%"
      end
    end
  end
end

ExampleWindow.new.show