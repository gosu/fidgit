require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    pack :horizontal do
      label "Top Left"
      label "Top Centre"
      label "Top Right"
    end

    pack :horizontal do
      label "Middle Left"
      label "Middle Centre"
      label "Middle Right"
    end

    pack :horizontal do
      label "Bottom Left"
      label "Bottom Centre"
      label "Bottom Right"
    end
  end
end

ExampleWindow.new.show