# encoding: utf-8

module Fidgit
  class GuiWindow < Chingu::Window
    DEFAULT_HEIGHT, DEFAULT_WIDTH = 640, 480
    DEFAULT_FULL_SCREEN = false
    DEFAULT_UPDATE_INTERVAL = 1 / 60.0

    # @option options [Integer] :width (640)
    # @option options [Integer] :height (480)
    # @option options [Integer] :full_screen (false)
    # @option options [Integer] :update_interval (16.66666666)
    # @option options [String] :caption Initial caption.
    # @option options [Chingu::GameState, Fidgit::GuiState] :state Initial state, if any.
    def initialize(options = {})
      options = {
        width: DEFAULT_HEIGHT,
        height: DEFAULT_WIDTH,
        full_screen: DEFAULT_FULL_SCREEN,
        update_interval: DEFAULT_UPDATE_INTERVAL,
      }.merge! options

      super(options[:width], options[:height], options[:full_screen], options[:update_interval])

      self.caption = options[:caption] if options.has_key? :caption
      push_game_state options[:state] if options.has_key? :state
    end
  end
end