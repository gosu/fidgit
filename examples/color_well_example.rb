require_relative 'helpers/example_window'

class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical do
      my_label = label "No color selected."

      group do
        grid num_columns: 15, padding: 0, spacing: 4 do
          150.times do
            color_well(color: Gosu::Color.rgb(rand(255), rand(255), rand(255)))
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