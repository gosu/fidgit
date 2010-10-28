require_relative 'example/window'

class ExampleState < GuiState
  def setup
    Label.new(container, text: "Hello!", tip: 'A Fidgit label')
  end
end

Window.new.show