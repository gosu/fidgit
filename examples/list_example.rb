require_relative 'helpers/example_window'

# Labels can have text and/or icons.
class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical do
      my_label = label "No clicky"

      list do
        item "chunky bacon", :CHUNKYBACON, tip: "You prefer Chunky Bacon, don't you?"
        item "lentils", :LENTILS, tip: "Lentils? Well, I suppose someone has to like them"

        subscribe :changed do |sender, value|
          my_label.text = "I like #{value} more than anything in the world!"
        end
      end
    end
  end
end

ExampleWindow.new.show