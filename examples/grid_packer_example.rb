require_relative 'helpers/example_window'

class ExampleState < Fidgit::GuiState
  BORDER_COLOR = Gosu::Color.rgb(255, 0, 0)
  FIXED_NUM = 5
  NUM_CELLS = 17

  def initialize
    super

    vertical do
      label "Grid with #{FIXED_NUM} columns"
      grid num_columns: FIXED_NUM, border_color: BORDER_COLOR, cell_border_color: Gosu::Color.rgba(0, 255, 0, 255), cell_border_thickness: 1 do
        NUM_CELLS.times do |i|
          label "Cell #{i}", font_height: rand(15) + 15, border_color: BORDER_COLOR, border_thickness: 1
        end
      end

      label "Grid with #{FIXED_NUM} rows"
      grid num_rows: FIXED_NUM, border_color: BORDER_COLOR, cell_background_color: Gosu::Color.rgba(0, 100, 100, 255) do
        NUM_CELLS.times do |i|
          label "Cell #{i}", font_height: rand(15) + 15, border_color: BORDER_COLOR, border_thickness: 1
        end
      end
    end
  end
end

ExampleWindow.new.show