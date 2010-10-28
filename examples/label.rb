require_relative 'example/window'

class ExampleState < GuiState
  def setup
    Label.new(container, text: "A Fidgit label")
  end
end

Window.new.show