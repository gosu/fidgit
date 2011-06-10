require_relative 'helpers/example_window'

class ExampleState < Fidgit::GuiState
  def initialize
    super

    horizontal do
      vertical do
        label 'editable'
        text_area(width: 200)
      end

      vertical do
        label 'mirrors to right'
        text_area(width: 200, text: "Hello, my name in brian the snail!") do |sender, text|
          @mirror.text = text
        end
      end

      vertical do
        label 'not editable'
        @mirror = text_area(width: 200, enabled: false)
      end
    end
  end
end

ExampleWindow.new.show