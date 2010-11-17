require_relative 'helpers/example_window'

class ExampleState < GuiState
  def initialize
    super

    pack :vertical do
      my_label = label "No button selected"

      button("Deselect") do
        @group.value = nil
      end

      button("Select #7") do
        @group.value = 7
      end

      @group = group do
        pack :grid, num_columns: 5, padding: 0 do
          15.times do |i|
            radio_button "##{i}", i, width: 60
          end
        end

        subscribe :changed do |sender, value|
          my_label.text = if value
            "Button #{value.to_s} selected"
          else
            "No button selected"
          end
        end
      end
    end
  end
end

ExampleWindow.new.show