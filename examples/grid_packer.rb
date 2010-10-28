require_relative 'example/window'

class ExampleState < GuiState
  BORDER_COLOR = Gosu::Color.rgb(255, 0, 0)
  NUM_COLUMNS = 10
  NUM_CELLS = 150

  def setup
    GridPacker.new(container, num_columns: NUM_COLUMNS) do |packer|
      NUM_CELLS.times do |i|
        Label.new(packer, text: "Cell #{i}", border_color: BORDER_COLOR)
      end
    end
  end
end

Window.new.show