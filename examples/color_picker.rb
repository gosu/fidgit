require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    VerticalPacker.new(container) do |packer|
      label = Label.new(packer)

      ColorPicker.new(packer, width: 100) do |picker|
        picker.subscribe :changed do |sender, color|
          label.text = color.to_s
        end

        label.text = picker.color.to_s
      end
    end
  end
end

ExampleWindow.new.show