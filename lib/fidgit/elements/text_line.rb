module Fidgit
  # Used internally by the label.
  class TextLine < Element
    VALID_JUSTIFICATION = [:left, :right, :center]

    attr_reader :color, :justify

    def color=(color)
      raise ArgumentError.new("Text must be a Gosu::Color") unless color.is_a? Gosu::Color

      @color = color.dup

      color
    end

    def text; @text.dup; end

    def text=(text)
      raise ArgumentError.new("Text must be a String") unless text.respond_to? :to_s

      @text = text.to_s.dup

      recalc
      text
    end

    def justify=(justify)
      raise ArgumentError.new("Justify must be one of #{VALID_JUSTIFICATION.inspect}") unless VALID_JUSTIFICATION.include? justify
      @justify = justify
    end

    # @param (see Element#initialize)
    # @param [String] text The string to display in the line of text.
    #
    # @option (see Element#initialize)
    # @option options [:left, :right, :center] :justify (:left) Text justification.
    def initialize(text, options = {})
      options = {
          color: default(:color),
          justify: default(:justify),
      }.merge! options

      super(options)

      self.justify = options[:justify]
      self.color = options[:color]
      self.text = text
    end

    def draw_foreground
      case @justify
        when :left
          rel_x = 0.0
          draw_x = x + padding_left

        when :right
          rel_x = 1.0
          draw_x = x + rect.width - padding_right

        when :center
          rel_x = 0.5
          draw_x = (x + padding_left) + (rect.width - padding_right - padding_left) / 2.0
      end

      font.draw_rel(@text, draw_x, y + padding_top, z, rel_x, 0, 1, 1, color)
    end

    def min_width
      if @text.empty?
        [padding_left + padding_right, super].max
      else
        [padding_left + font.text_width(@text) + padding_right, super].max
      end
    end

    protected
    def layout
      rect.width = [min_width, max_width].min

      if @text.empty?
        rect.height = [[padding_top + padding_bottom, min_height].max, max_height].min
      else
        rect.height = [[padding_top + font.height + padding_bottom, min_height].max, max_height].min
      end
    end

    public
    def to_s
      "#{super} '#{@text}'"
    end
  end
end