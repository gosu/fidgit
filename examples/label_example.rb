require_relative 'helpers/example_window'

# Labels can have text and/or icons.
class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical background_color: Gosu::Color.rgb(255, 0, 0) do
      label "Hello!", tip: 'A label with text'
      label "Hello!", icon: Gosu::Image["head_icon.png"], tip: 'A label with text & icon'
      label '', icon: Gosu::Image["head_icon.png"], tip: 'A label with just icon'
      label '', background_color: Gosu::Color.rgb(0, 255, 0), tip: 'No text or icon'
    end

    vertical do
      label ":left justification", width: 400, background_color: Gosu::Color.rgb(0, 100, 0), justify: :left, tip: 'A label with text'
      label ":right justification", width: 400, background_color: Gosu::Color.rgb(0, 100, 0), justify: :right, tip: 'A label with text'
      label ":center justification", width: 400, background_color: Gosu::Color.rgb(0, 100, 0), justify: :center, tip: 'A label with text'
    end
  end
end

ExampleWindow.new.show