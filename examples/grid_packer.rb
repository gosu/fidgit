require_relative 'helpers/example_window'

class ExampleState < GuiState
  BORDER_COLOR = Gosu::Color.rgb(255, 0, 0)
  NUM_COLUMNS = 5
  NUM_CELLS = 48

  def setup
    GridPacker.new(container, num_columns: NUM_COLUMNS) do |packer|
      NUM_CELLS.times do |i|
        Label.new(packer, text: "Cell #{i}", font_size: rand(10) + 20, border_color: BORDER_COLOR)
      end
    end
  end
end

ExampleWindow.new.show