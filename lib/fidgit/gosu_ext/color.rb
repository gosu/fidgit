# encoding: utf-8

module Gosu
  class Color
    # Is the color completely transparent?
    def transparent?; alpha == 0; end
    # Is the color completely opaque?
    def opaque?; alpha == 255; end

    # RGB in 0..255 format (Alpha assumed 255)
    #
    # @param [Integer] red
    # @param [Integer] green
    # @param [Integer] blue
    # @return [Color]
    def self.rgb(red, green, blue)
      new(255, red, green, blue)
    end

    # RGBA in 0..255 format
    #
    # @param [Integer] red
    # @param [Integer] green
    # @param [Integer] blue
    # @param [Integer] alpha
    # @return [Color]
    def self.rgba(red, green, blue, alpha)
      new(alpha, red, green, blue)
    end

    # ARGB in 0..255 format (equivalent to Color.new, but explicit)
    #
    # @param [Integer] alpha
    # @param (see Color.rgb)
    # @return [Color]
    def self.argb(alpha, red, green, blue)
      new(alpha, red, green, blue)
    end

    # HSV format (alpha assumed to be 255)
    #
    # @param [Float] hue 0.0..360.0
    # @param [Float] saturation 0.0..1.0
    # @param [Float] value 0.0..1.0
    # @return [Color]
    def self.hsv(hue, saturation, value)
      from_hsv(hue, saturation, value)
    end

    # HSVA format
    #
    # @param [Float] hue 0.0..360.0
    # @param [Float] saturation 0.0..1.0
    # @param [Float] value 0.0..1.0
    # @param [Integer] alpha 1..255
    # @return [Color]
    def self.hsva(hue, saturation, value, alpha)
      from_ahsv(alpha, hue, saturation, value)
    end

    class << self
      alias_method :ahsv, :from_ahsv
    end

    # Convert from an RGBA array, as used by TexPlay.
    #
    # @param [Array<Float>] color TexPlay color [r, g, b, a] in range 0.0..1.0
    # @return [Color]
    def self.from_tex_play(color)
      rgba(*color.map {|c| (c * 255).to_i })
    end

    # Convert to an RGBA array, as used by TexPlay.
    #
    # @return [Array<Float>] TexPlay color array [r, g, b, a] in range 0.0..1.0
    def to_tex_play
      [red / 255.0, green / 255.0, blue / 255.0,  alpha / 255.0]
    end

    # Show the Color as <RGBA [0, 0, 0, 0]> or, if opaque, <RGB [0, 0, 0]> (Gosu default is '(ARGB:0/0/0/0)')
    def to_s
      if opaque?
        "<RGB [#{red}, #{green}, #{blue}]>"
      else
        "<RGBA [#{red}, #{green}, #{blue}, #{alpha}]>"
      end
    end

    def +(other)
      raise ArgumentError, "Can only add another #{self.class}" unless other.is_a? Color

      copy = Color.new(0)

      copy.red = [red + other.red, 255].min
      copy.green = [green + other.green, 255].min
      copy.blue = [blue + other.blue, 255].min
      copy.alpha = [alpha + other.alpha, 255].min

      copy
    end

    def -(other)
      raise ArgumentError, "Can only take away another #{self.class}" unless other.is_a? Color

      copy = Color.new(0)

      copy.red = [red - other.red, 0].max
      copy.green = [green - other.green, 0].max
      copy.blue = [blue - other.blue, 0].max
      copy.alpha = [alpha - other.alpha, 0].max

      copy
    end

    def ==(other)
      if other.is_a? Color
        red == other.red and green == other.green and blue == other.blue and alpha == other.alpha
      else
        false
      end
    end
  end
end