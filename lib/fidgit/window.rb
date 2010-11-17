# encoding: utf-8

module Fidgit
  class Window < Chingu::Window
    def close
      super

      GuiState.clear
    end
  end
end