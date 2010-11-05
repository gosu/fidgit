require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    pack :horizontal do
      pack :vertical do
        label 'editable'
        text_area(width: 200)
      end

      pack :vertical do
        label 'mirrors to right'
        text_area(width: 200, text: "Hello, my name in brian the snail!") do |sender, text|
          @mirror.text = text
        end
      end

      pack :vertical do
        label 'not editable'
        @mirror = text_area(width: 200, enabled: false)
      end
    end
  end
end

ExampleWindow.new.show