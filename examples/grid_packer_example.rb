require_relative 'helpers/example_window'

class ExampleState < GuiState
  BORDER_COLOR = Gosu::Color.rgb(255, 0, 0)
  FIXED_NUM = 5
  NUM_CELLS = 17

  def setup
    pack :vertical do
      label "Grid with #{FIXED_NUM} columns"
      pack :grid, num_columns: FIXED_NUM, border_color: BORDER_COLOR, cell_border_color: Gosu::Color.rgba(0, 255, 0, 255) do
        NUM_CELLS.times do |i|
          label "Cell #{i}", font_size: rand(15) + 15, border_color: BORDER_COLOR
        end
      end

      label "Grid with #{FIXED_NUM} rows"
      pack :grid, num_rows: FIXED_NUM, border_color: BORDER_COLOR, cell_background_color: Gosu::Color.rgba(0, 100, 100, 255) do
        NUM_CELLS.times do |i|
          label "Cell #{i}", font_size: rand(15) + 15, border_color: BORDER_COLOR
        end
      end
    end
  end
end

ExampleWindow.new.show