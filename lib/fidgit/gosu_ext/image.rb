# encoding: utf-8

# Temporary patch.

module Gosu
  class Image
    def self.create(width, height, options = {})
      TexPlay.create_image($window, width, height, options)
    end
  end
end