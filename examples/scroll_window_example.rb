require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  HEIGHT = 225
  WIDTH = 140
  def setup
    pack :vertical do
      pack :horizontal do
        [
            [20, "All cheer the ascendancy of number "], # Should have both scrollers
            [20, "#"],                                   # Only has v-scroller.
            [4, "#"],                                    # No scrollers.
            [4, "All cheer the ascendancy of number "],  # Only has h-scroller
        ].each do |num_labels, text|
          pack :vertical do
            scroller = scroll_window(width: WIDTH, height: HEIGHT, background_color: Gosu::Color.rgb(0, 100, 0)) do
              pack :vertical do
                (1..num_labels).each do |i|
                  label "#{text}#{i}!"
                end
              end
            end

            slider(width: WIDTH) do |sender, value|
              scroller.offset_x = (scroller.content_width - scroller.view_width) * value
              scroller.offset_y = (scroller.content_height - scroller.view_height) * value
            end
          end
        end
      end

      scroller = scroll_window(width: 300, height: 150) do
        text_area(text: "Hello world! " * 19, width: 300)
      end

      slider(width: 300) do |sender, value|
        scroller.offset_y = (scroller.content_height - scroller.view_height) * value
      end
    end
  end
end

ExampleWindow.new.show