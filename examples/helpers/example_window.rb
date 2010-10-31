require_relative '../../lib/fidgit'
include Fidgit

Element.default_font_size = 30

media_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'media'))
Gosu::Image.autoload_dirs << File.join(media_dir, 'images')
Gosu::Sample.autoload_dirs << File.join(media_dir, 'sounds')

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