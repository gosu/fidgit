require_relative 'helpers/example_window'

class ExampleState < Fidgit::GuiState
  def initialize
    super

    vertical do
      horizontal do
        # Discrete values (0..100)
        slider = slider(width: 100, range: 0..5, value: 3) do |sender, value|
          @discrete_label.text = "Discrete slider is at #{value}"
        end

        @discrete_label = label "Discrete slider is at #{slider.value}"
      end

      horizontal do
        # Continuous values (0.0..1.0)

        slider = slider(width: 100, range: 0.0..100.0, value: 77.2) do |sender, value|
          @continuous_label.text = "Continuous slider is at #{"%.03f" % value}%"
        end

        @continuous_label = label "Continuous slider is at #{"%.03f" % slider.value}%"
      end
    end
  end
end

ExampleWindow.new.show