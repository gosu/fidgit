require_relative 'window'

class ExampleState < GuiState
  def setup
    Label.new(container, text: "A Fidgit label")
  end
end

Window.new.show