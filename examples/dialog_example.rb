require_relative 'helpers/example_window'

# Example for Button and ToggleButton
class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label "Label", tip: "I'm a label"

      button text: "Open an ok dialog" do
        MessageDialog.new("System shutdown immanent").show
      end

      button text: "Open an ok/cancel dialog" do
        dialog = MessageDialog.new("Do you like any sorts of cheese? Even Government cheese counts, you know!", type: :ok_cancel) do |result|
          case result
            when :ok
              my_label.text = "You like cheese"
            when :cancel
              my_label.text = "You don't like cheese"
          end
        end

        dialog.show
      end

      button text: "Open yes/no/cancel dialog" do
        dialog = MessageDialog.new("You have unsaved data.\nSave before quitting?",
                                   type: :yes_no_cancel, yes_text: "Save", no_text: "Discard") do |result|
          case result
            when :yes
              my_label.text = "File saved and quit"
            when :no
              my_label.text = "File discarded and quit"
            when :cancel
              my_label.text = "Nothing happened"
          end
        end

        dialog.show
      end
    end
  end
end

ExampleWindow.new.show