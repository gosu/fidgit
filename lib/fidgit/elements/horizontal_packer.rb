# encoding: utf-8

require_relative 'packer'

module Fidgit
  # A vertically aligned element packing container.
  class HorizontalPacker < GridPacker
    def initialize(options = {})
      options[:num_rows] = 1

      super options
    end
  end
end