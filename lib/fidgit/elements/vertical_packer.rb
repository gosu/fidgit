# encoding: utf-8

module Fidgit
  # A vertically aligned element packing container.
  class VerticalPacker < GridPacker
    def initialize(options = {})
      options[:num_columns] = 1

      super options
    end
  end
end