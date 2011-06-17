module Fidgit
  # A wrapper around a Gosu::Image to show it in the GUI.
  class ImageFrame < Element
    ENABLED_COLOR = Gosu::Color::WHITE
    DISABLED_COLOR = Gosu::Color.rgb(150, 150, 150)

    attr_reader :image, :factor_x, :factor_y

    def thumbnail?; @thumbnail; end

    # @param (see Element#initialize)
    # @param [Gosu::Image] image Gosu image to display.
    #
    # @option (see Element#initialize)
    # @option options [Boolean] :thumbnail (false) Is the image expanded to be square?
    def initialize(image, options = {})
      options = {
          thumbnail: false,
          factor: 1,
      }.merge! options

      @thumbnail = options[:thumbnail]
      @factor_x = options[:factor_x] || options[:factor]
      @factor_y = options[:factor_y] || options[:factor]

      super(options)

      self.image = image
    end

    def image=(image)
      @image = image

      recalc

      image
    end


    def draw_foreground
      @image.draw(x + padding_left, y + padding_top, z, factor_x, factor_y, enabled? ? ENABLED_COLOR : DISABLED_COLOR) if @image
    end

    protected
    def layout
      if @image
        if @thumbnail
          size = [@image.width, @image.height].max
          rect.width = size * @factor_x
          rect.height = size * @factor_y
        else
          rect.width = @image.width * @factor_x
          rect.height = @image.height * @factor_y
        end
      else
        rect.width = rect.height = 0
      end

      rect.width += padding_left + padding_right
      rect.height += padding_top + padding_bottom

      nil
    end
  end
end