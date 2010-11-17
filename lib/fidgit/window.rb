# encoding: utf-8

module Fidgit
  class Window < Chingu::Window
    def close
      super

      GuiState.clear

      # Todo: when Chingu is updated, remove this.
      Fidgit.fonts.clear
      Gosu::Image.instance_variable_set :@resources, {}
      Gosu::Song.instance_variable_set :@resources, {}
      Gosu::Sample.instance_variable_set :@resources, {}
    end
  end
end