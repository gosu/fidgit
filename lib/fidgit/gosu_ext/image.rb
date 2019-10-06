module Gosu
  EmptyImageSource = Struct.new(:columns, :rows) do
    def to_blob
      "\0\0\0\0" * (columns * rows)
    end
  end
  
  class Image
    def self.create(width, height)
      self.new(EmptyImageSource.new(width, height))
    end
  end
end
