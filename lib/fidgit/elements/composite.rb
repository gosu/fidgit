# encoding: utf-8

require_relative 'packer'

module Fidgit
  # A composite element, made up of other elements (but manages them internally).
  class Composite < Packer
    DEBUG_BORDER_COLOR = Gosu::Color.rgba(0, 255, 0, 100) # Color to draw an outline in when debugging layout.

    # @param (see Element#initialize)
    #
    # @option (see Element#initialize)
    def initialize(options = {})
      options[:border_color] = DEBUG_BORDER_COLOR if Fidgit.debug_mode?

      super(options)
    end
  end
end