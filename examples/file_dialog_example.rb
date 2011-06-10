require_relative 'helpers/example_window'


Fidgit::Element.schema.merge_elements!(Element: { font_size: 15 })

class ExampleState < Fidgit::GuiState
  def initialize
    super

    container.background_color = Gosu::Color.rgb(50, 50, 50)
    vertical align: :center do
      full_base_directory = ''
      restricted_base_directory = File.expand_path(File.join(__FILE__, '..', '..'))
      directory = File.join(restricted_base_directory, 'media', 'images')

      my_label = label "No files are actually loaded or saved by this example"
      button("Load...(limited path access)") do
        file_dialog(:open, base_directory: restricted_base_directory, directory: directory, pattern: "*.png") do |result, file|
          case result
            when :open
              my_label.text = "Loaded #{file}"
            when :cancel
              my_label.text = "Loading cancelled"
          end
        end
      end

      button("Save...(unrestricted path access)") do
        file_dialog(:save, base_directory: full_base_directory, directory: directory, pattern: "*.png") do |result, file|
          case result
            when :save
              my_label.text = "Saved #{file}"
            when :cancel
              my_label.text = "Save cancelled"
          end
        end
      end
    end
  end
end

ExampleWindow.new.show