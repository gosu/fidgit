require_relative 'helpers/example_window'

class ExampleState < GuiState
  ROW_BACKGROUND = Gosu::Color.rgb(0, 100, 0)
  CELL_BACKGROUND = Gosu::Color.rgb(100, 0, 0)

  def setup
    pack :horizontal, cell_background_color: CELL_BACKGROUND, background_color: ROW_BACKGROUND do
      label "Top Left"
      label "Top Centre"
      label "Top Right"
    end

    pack :horizontal, cell_background_color: CELL_BACKGROUND, background_color: ROW_BACKGROUND do
      label "Middle Left"
      label "Middle Centre"
      label "Middle Right"
    end

    pack :horizontal, cell_background_color: CELL_BACKGROUND, background_color: ROW_BACKGROUND do
      label "Bottom Left"
      label "Bottom Centre"
      label "Bottom Right"
    end
  end
end

ExampleWindow.new.show