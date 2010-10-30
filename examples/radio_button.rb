require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    VerticalPacker.new(container) do |packer|
      label = Label.new(packer, text: "No button selected")

      Button.new(packer, text: "Deselect") do |button|
        button.subscribe :clicked_left_mouse_button do |sender, x, y|
          @group.value = nil
        end
      end

      Button.new(packer, text: "Select #7") do |button|
        button.subscribe :clicked_left_mouse_button do |sender, x, y|
          @group.value = 7
        end
      end

      @group = RadioButton::Group.new(packer, padding_y: 10) do |group|
        GridPacker.new(group, num_columns: 5, padding: 0, spacing: 4) do |packer|
          15.times do |i|
            RadioButton.new(packer, i, text: "##{i}", width: 60)
          end
        end

        group.subscribe :changed do |sender, value|
          label.text = if value
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