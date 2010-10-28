require_relative '../../lib/fidgit'
include Fidgit

Element.default_font_size = 30

class Window < Chingu::Window
  def initialize
    super(640, 480, false)

    self.caption = "Example: #{File.basename($0).chomp(".rb").tr('_', ' ')}"

    push_game_state ExampleState
  end

  def needs_cursor?
    false
  end
end