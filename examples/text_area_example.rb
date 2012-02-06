require_relative 'helpers/example_window'

class ExampleState < Fidgit::GuiState
  def initialize
    super

    Gosu.register_entity(:entity, Gosu::Image["head_icon.png"])

    string = "<c=3333ff>Hello, my name</c> is <c=ff0000>Brian</c> the&entity;&entity;snail!"
    horizontal do
      vertical do
        label 'disabled'
        text_area(text: "Can't even select this text", width: 200, enabled: false)
      end

      vertical do
        label 'mirrors to right'
        text_area(width: 200, text: string) do |_, text|
          @mirror.text = text
        end
      end

      vertical do
        my_label = label 'not editable'
        font = Gosu::Font.new($window, "", my_label.font.height)
        font["a"] = Gosu::Image["head_icon.png"]
        @mirror = text_area(text: string, width: 200, editable: false, font: font)
      end
    end
  end
end

ExampleWindow.new.show