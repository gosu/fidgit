require_relative 'helpers/example_window'

# Labels can have text and/or icons.
class ExampleState < GuiState
  def initialize
    super

    pack :vertical, background_color: Gosu::Color.rgb(255, 0, 0) do
      label "Hello!", tip: 'A label with text'
      label "Hello!", icon: Gosu::Image["head_icon.png"], tip: 'A label with text & icon'
      label '', icon: Gosu::Image["head_icon.png"], tip: 'A label with just icon'
      label '', background_color: Gosu::Color.rgb(0, 255, 0), tip: 'No text or icon'
    end
  end
end

ExampleWindow.new.show