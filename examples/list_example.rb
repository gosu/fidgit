require_relative 'helpers/example_window'

# Labels can have text and/or icons.
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "No clicky"

      list do
        item :CHUNKYBACON, text: "chunky bacon"
        item :LENTILS, text: "lentils"

        subscribe :changed do |sender, value|
          my_label.text = "I like #{value} more than anything in the world!"
        end
      end
    end
  end
end

ExampleWindow.new.show