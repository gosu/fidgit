require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "Why not open a dialog? You know you want to!", tip: "I'm a label"

      button(text: "Open an ok dialog") do
        MessageDialog.new("System shutdown immanent").show
      end

      button(text: "Open an ok/cancel dialog") do
        dialog = MessageDialog.new("Really 'rm -rf .'?", type: :ok_cancel) do |result|
          my_label.text = case result
            when :ok     then "All your base are belong to us!"
            when :cancel then "Cancelled"
          end
        end

        dialog.show
      end

      button(text: "Open a yes/no dialog") do
        dialog = MessageDialog.new("Do you like any sorts of cheese? Even Government cheese counts, you know!", type: :yes_no) do |result|
          my_label.text = case result
            when :yes then "You like cheese"
            when :no  then "You don't like cheese"
          end
        end

        dialog.show
      end

      button(text: "Open a yes/no/cancel dialog") do
        dialog = MessageDialog.new("Do you know what you are doing?", type: :yes_no_cancel) do |result|
          my_label.text = case result
            when :yes    then "I'm not convinced you know what you are doing"
            when :no     then "At least you are aware of your own shortcomings"
            when :cancel then "Don't avoid the question!"
          end
        end

        dialog.show
      end

      button(text: "Open quit/cancel dialog") do
        dialog = MessageDialog.new("Really leave us?",
                                   type: :quit_cancel) do |result|
          my_label.text = case result
            when :quit   then "Quit! Bye!"
            when :cancel then "Oh, you are staying? Yay!"
          end
        end

        dialog.show
      end

      button(text: "Open quit/save/cancel dialog") do
        dialog = MessageDialog.new("You have unsaved data.\nSave before quitting?",
                                   type: :quit_save_cancel) do |result|
          my_label.text = case result
            when :quit   then "File discarded and quit"
            when :save   then "File saved and quit"
            when :cancel then "Nothing happened. You should be more committed"
          end
        end

        dialog.show
      end
    end
  end
end

ExampleWindow.new.show