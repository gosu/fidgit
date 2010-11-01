require_relative 'helpers/example_window'

class ExampleState < GuiState
  def setup
    pack :vertical do
      my_label = label text: "No color selected."

      group do
        pack :grid, num_columns: 15, padding: 0, spacing: 4 do
          150.times do
            color_well color: Gosu::Color.rgb(rand(255), rand(255), rand(255))
          end
        end

        subscribe :changed do |sender, color|
          my_label.text = color.to_s
        end
      end
    end
  end
end

ExampleWindow.new.show