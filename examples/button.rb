require_relative 'example/window'

class ExampleState < GuiState
  def setup
    VerticalPacker.new(container) do |packer|
      label = Label.new(packer, text: "Label")

      Button.new(packer, text: "Button") do |button|
        button.subscribe :clicked_left_mouse_button do |sender, x, y|
          label.text = "Pressed the button!"
        end
      end
    end
  end
end

Window.new.show