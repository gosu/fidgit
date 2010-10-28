require_relative '../lib/fidgit'
include Fidgit

class Window < Chingu::Window
  def initialize
    super(640, 480, false)

    self.caption = "Example: #{File.basename($0).chomp(".rb").tr('_', ' ')}"

    push_game_state ExampleState
  end
end