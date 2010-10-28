# encoding: utf-8

module Fidgit
  # Wrapper for Gosu::Image that always pads the image out to being square.
  class Icon
    DEFAULT_COLOR = Gosu::Color.rgb(255, 255, 255)

    attr_reader :image, :height, :width

    public
    def image=(value)
      @image = value
      @height = [@image.width, @image.height].max
      @width = [@image.width, @image.height].max

      value
    end

    protected
    def initialize(image)
      raise ArgumentError, "image must be a Gosu::Image" unless image.is_a? Gosu::Image
      self.image = image
    end

    public
    def draw(x, y, z_order, scale_x = 1, scale_y = 1, color = DEFAULT_COLOR, mode = :default)
      @image.draw x + (@width - @image.width) * scale_x / 2, y + (@height - @image.height) * scale_y / 2, z_order, scale_x, scale_y, color, mode

      nil
    end
  end
end