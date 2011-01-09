# encoding: utf-8

module Fidgit
  module Window

    def self.included(base)
      base.send :include, Methods
    end

    module Methods

      def close
        super
        GuiState.clear
      end
    end
    
  end
end
