module Fidgit
  class Label < Composite
    ICON_POSITIONS = [:top, :bottom, :left, :right]

    attr_reader :icon_position

    attr_accessor :background_color, :border_color

    def_delegators :@text, :text, :color, :font, :color=, :text=

    def icon; @icon ? @icon.image : nil; end

    def hit_element(x, y)
      # The sub-elements should never get events.
      hit?(x, y) ? self : nil
    end

    def icon=(icon)
      raise ArgumentError.new("Icon must be a Gosu::Image") unless icon.is_a? Gosu::Image or icon.nil?

      @contents.remove(@icon) if @icon.image
      @icon.image = icon
      position = [:left, :top].include?(icon_position) ? 0 : 1
      @contents.insert(position, @icon) if @icon.image

      icon
    end

    # Set the position of the icon, respective to the text.
    def icon_position=(position)
      raise ArgumentError.new("icon_position must be one of #{ICON_POSITIONS}") unless ICON_POSITIONS.include? position

      @icon_position = position

      case @icon_position
        when :top, :bottom
          @contents.instance_variable_set :@type, :fixed_columns
          @contents.instance_variable_set :@num_columns, 1
        when :left, :right
          @contents.instance_variable_set :@type, :fixed_rows
          @contents.instance_variable_set :@num_rows, 1
      end

      self.icon = @icon.image if @icon.image # Force the icon into the correct position.

      position
    end

    # @param (see Element#initialize)
    # @param [String] text The string to display in the label.
    #
    # @option (see Element#initialize)
    # @option options [Gosu::Image, nil] :icon (nil)
    # @option options [:left, :right, :center] :justify (:left) Text justification.
    def initialize(text, options = {})
      options = {
        color: default(:color),
        justify: default(:justify),
        background_color: default(:background_color),
        border_color: default(:border_color),
        icon_options: {},
        font_name: default(:font_name),
        font_height: default(:font_height),
        icon_position: default(:icon_position),
      }.merge! options

      super(options)

      # Bit of a fudge since font info is managed circularly here!
      # By using a grid, we'll be able to turn it around easily (in theory).
      @contents = grid num_rows: 1, padding: 0, spacing_h: spacing_h, spacing_v: spacing_v, width: options[:width], height: options[:height], z: z do |contents|
        @text = TextLine.new(text, parent: contents, justify: options[:justify], color: options[:color], padding: 0, z: z,
                               font_name: options[:font_name], font_height: options[:font_height], align_h: :fill, align_v: :center)
      end

      # Create an image frame, but don't show it unless there is an image in it.
      @icon = ImageFrame.new(nil, options[:icon_options].merge(z: z, align: :center))
      @icon.image = options[:icon]

      self.icon_position = options[:icon_position]
    end
  end
end