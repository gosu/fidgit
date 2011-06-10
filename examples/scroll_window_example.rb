require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < Fidgit::GuiState
  HEIGHT = 225
  WIDTH = 140
  def initialize
    super

    vertical do
      horizontal do
        [
            [20, "All cheer the ascendancy of number "], # Should have both scrollers
            [20, "#"],                                   # Only has v-scroller.
            [4, "#"],                                    # No scrollers.
            [4, "All cheer the ascendancy of number "],  # Only has h-scroller
        ].each do |num_labels, text|
          vertical do
            scroll_window(width: WIDTH, height: HEIGHT, background_color: Gosu::Color.rgb(0, 100, 0)) do
              vertical do
                (1..num_labels).each do |i|
                  label "#{text}#{i}!"
                end
              end
            end
          end
        end
      end

      horizontal padding: 0 do
        vertical do
          scroll_window(width: 300, height: 150) do
            text_area(text: "Hello world! " * 19, width: 284)
          end
        end

        vertical do
          scroll_window(width: 300, height: 150) do
            %w[One Two Three Four Five Six].each do |name|
              toggle_button(name)
            end
          end
        end
      end
    end
  end
end

ExampleWindow.new.show