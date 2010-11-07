# encoding: utf-8

require_relative 'packer'

module Fidgit
  # A vertically aligned element packing container.
  class VerticalPacker < GridPacker
    def initialize(parent, options = {})
      options[:num_columns] = 1

      super parent, options
    end
  end
end