require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    VerticalPacker.new(container) do |packer|
      label = Label.new(packer, text: "No color selected.")

      ColorWell::Group.new(packer) do |group|
        GridPacker.new(group, num_columns: 15, padding: 0, spacing: 4) do |packer|
          150.times do
            ColorWell.new(packer, color: Gosu::Color.rgb(rand(255), rand(255), rand(255)))
          end
        end

        group.subscribe :changed do |sender, color|
          label.text = color.to_s
        end
      end
    end
  end
end

ExampleWindow.new.show