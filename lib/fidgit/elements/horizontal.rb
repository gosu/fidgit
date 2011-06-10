# encoding: utf-8

module Fidgit
  # A vertically aligned element packing container.
  class Horizontal < Grid
    def initialize(options = {})
      options[:num_rows] = 1

      super options
    end
  end
end