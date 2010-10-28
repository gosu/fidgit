# encoding: utf-8

module Gosu
  class Color
    def transparent?; alpha == 0; end

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
    public
    def to_tex_play
      [red / 255.0, green / 255.0, blue / 255.0,  alpha / 255.0]
    end
  end
end