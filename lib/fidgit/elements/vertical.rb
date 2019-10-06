module Fidgit
  # A vertically aligned element packing container.
  class Vertical < Grid
    def initialize(options = {})
      options[:num_columns] = 1

      super options
    end
  end
end