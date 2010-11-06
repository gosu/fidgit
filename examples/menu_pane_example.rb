require_relative 'helpers/example_window'

# Labels can have text and/or icons.
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "Right click to open context menu"

      my_label.subscribe :released_right_mouse_button do
        menu do
          item :CHUNKYBACON, text: "chunky bacon", shortcut: "Ctrl-^-*"
          separator
          item :LENTILS, text: "lentils", shortcut: "Alt-F15"
          item :GRUEL, text: "tepid gruel", shortcut: "CenterMeta"

          subscribe :selected do |sender, value|
            my_label.text = "I like #{value} more than anything. Mmmm!"
          end
        end
      end
    end
  end
end

ExampleWindow.new.show