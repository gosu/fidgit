require_relative 'helpers/example_window'

# Labels can have text and/or icons.
class ExampleState < GuiState
  def setup
    VerticalPacker.new(container, background_color: Gosu::Color.rgb(255, 0, 0)) do |packer|
      Label.new(packer, text: "Hello!", tip: 'A label with text')
      Label.new(packer, text: "Hello!", icon: Gosu::Image["head_icon.png"], tip: 'A label with text & icon')
      Label.new(packer, icon: Gosu::Image["head_icon.png"], tip: 'A label with just icon')
      Label.new(packer, background_color: Gosu::Color.rgb(0, 255, 0), tip: 'No text or icon')
    end
  end
end

ExampleWindow.new.show