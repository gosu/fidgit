# encoding: utf-8

module Fidgit
  class Label < Element
    attr_accessor :color, :background_color, :border_color
    attr_reader :text, :icon

    VALID_JUSTIFICATION = [:left, :right, :center]

    def text=(value)
      @text = value
      recalc
      nil
    end

    def icon=(value)
      @icon = value
      recalc
      nil
    end

    # @param (see Element#initialize)
    # @param [String] text The string to display in the label.
    #
    # @option (see Element#initialize)
    # @option options [Fidgit::Thumbnail, Gosu::Image, nil] :icon (nil)
    # @option options [:left, :right, :center] :justify (:left) Text justification.
    def initialize(text, options = {})
      options = {
        color: default(:color),
        justify: default(:justify),
        background_color: default(:background_color),
        border_color: default(:border_color),
      }.merge! options

      @text = text.dup
      @icon = options[:icon]
      @color = options[:color].dup

      raise "Justification must be one of #{VALID_JUSTIFICATION.inspect}" unless VALID_JUSTIFICATION.include? options[:justify]
      @justify = options[:justify]

      super(options)

      self.text = text # Forces stuff that manipulates text to work.
    end

    def draw_foreground
      current_x = x + padding_left
      if @icon
        @icon.draw(current_x, y + padding_top, z)
        current_x += @icon.width + padding_left
      end

      unless @text.empty?
        case @justify
          when :left
            rel_x = 0.0
            center_x = current_x

          when :right
            rel_x = 1.0
            center_x = x + rect.width - padding_right

          when :center
            rel_x = 0.5
            center_x = (current_x + x + rect.width - padding_right) / 2.0
        end

        font.draw_rel(@text, center_x, y + padding_top, z, rel_x, 0, 1, 1, @color)
      end

      nil
    end

    protected
    def layout
      if @icon
        if @text.empty?
          rect.width = [padding_left + @icon.width + padding_right, min_width].max
          rect.height = [padding_top + @icon.height + padding_bottom, min_height].max
        else
          # Todo: Use padding_h inside here? Probably by making this a Composite.
          rect.width = [padding_left + @icon.width + [padding_left + padding_right].max + font.text_width(@text) + padding_right, min_width].max
          rect.height = [padding_top + [@icon.height, font_size].max + padding_bottom, min_height].max
        end
      else
        if @text.empty?
          rect.width = [padding_left + padding_right, min_width].max
          rect.height = [padding_top + padding_bottom, min_height].max
        else
          rect.width = [padding_left + font.text_width(@text) + padding_right, min_width].max
          rect.height = [padding_top + font_size + padding_bottom, min_height].max
        end
      end

      nil
    end
  end
end