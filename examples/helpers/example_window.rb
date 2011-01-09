require_relative '../../lib/fidgit'

media_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', 'media'))
Gosu::Image.autoload_dirs << File.join(media_dir, 'images')
Gosu::Sample.autoload_dirs << File.join(media_dir, 'samples')
Gosu::Font.autoload_dirs << File.join(media_dir, 'fonts')

class ExampleWindow < Chingu::Window
  include Fidgit::Window
  
  def initialize(options = {})
    super(640, 480, false)

    on_input(:escape) { close }

    caption = "#{File.basename($0).chomp(".rb").tr('_', ' ')} #{ENV['FIDGIT_EXAMPLES_TEXT']}"
    push_game_state ExampleState
  end
end