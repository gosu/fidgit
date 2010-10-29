require_relative '../../lib/fidgit'
include Fidgit

Element.default_font_size = 30

class ExampleWindow < Fidgit::GuiWindow
  def initialize(options = {})
    default_caption = "Example: #{File.basename($0).chomp(".rb").tr('_', ' ')} #{ENV['FIDGIT_EXAMPLES_TEXT']}"

    options = {
      state: ExampleState,
      caption: default_caption,
    }.merge! options

    super(options)
  end

  def needs_cursor?
    false
  end
end