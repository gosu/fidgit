require_relative 'helpers/example_window'

# Labels can have text and/or icons.
class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical do
      my_label = label "Right click to open context menu"

      my_label.subscribe :released_right_mouse_button do
        menu do
          item "Chunky bacon", :CHUNKY_BACON, shortcut_text: "Ctrl-^-*"
          separator
          item "Lentils", :LENTILS, shortcut_text: "Alt-F15"
          item "Tepid gruel", :GRUEL, shortcut_text: "CenterMeta"

          subscribe :selected do |sender, value|
            my_label.text = "I like #{value} more than anything. Mmmm!"
          end
        end
      end
    end
  end
end

ExampleWindow.new.show