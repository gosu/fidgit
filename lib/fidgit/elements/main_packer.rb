require_relative "vertical"

module Fidgit
  # Main container that can contains a single "proper" packing element.
  class MainPacker < Vertical
    def initialize(options = {})
      options = {
          width: $window.width,
          height: $window.height,
      }.merge! options

      super options
    end

    def width; $window.width; end
    def height; $window.height; end
    def width=(value); ; end
    def height=(value); ; end

    def add(element)
      raise "MainPacker can only contain one packing element" unless empty?
      raise "MainPacker can only contain packing elements" unless element.is_a? Packer
      super(element)
    end
  end
end