require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    Label.new(container, text: "Hello!", tip: 'A Fidgit label')
  end
end

ExampleWindow.new.show