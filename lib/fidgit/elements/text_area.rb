# encoding: utf-8

module Fidgit
  class TextArea < Element
    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(50, 50, 50)
    DEFAULT_BORDER_COLOR_FOCUSED = Gosu::Color.rgb(0, 255, 255)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgb(200, 200, 200)

    CARET_COLOR = Gosu::Color.rgb(255, 0, 0)
    SELECTION_COLOR = Gosu::Color.rgb(100, 100, 100)
    CARET_PERIOD = 500 # ms

    # @return [Number]
    attr_reader :min_height
    # @return [Number]
    attr_reader :max_height

    # @return [Number]
    attr_reader :line_spacing

    # @param [Boolean] value
    # @return [Boolean]
    attr_writer :editable

    event :changed
    event :focus
    event :blur

    # Is the area editable?
    def editable?
      enabled?
    end

    # Text within the element.
    # @return [String]
    def text
      @text_input.text.force_encoding 'UTF-8'
    end

    # Returns the range of the selection.
    #
    # @return [Range]
    def selection_range
      from = [@text_input.selection_start, caret_position].min
      to = [@text_input.selection_start, caret_position].max

      (from...to)
    end

    # Returns the text within the selection.
    #
    # @return [String]
    def selection_text
      text[selection_range]
    end

    # Position of the caret.
    #
    # @return [Integer] Number in range 0..text.length
    def caret_position
      @text_input.caret_pos
    end

    # Position of the caret.
    #
    # @param [Integer] pos Position of caret in the text.
    # @return [Integer] New position of caret.
    def caret_position=(position)
      raise ArgumentError, "Caret position must be in the range 0 to the length of the text (inclusive)" unless position.between?(0, text.length)
      @text_input.caret_pos = position

      position
    end

    # Sets caret to the end of the text.
    #
    # @param [String] text
    # @return [String] Current string (may be the old one if passed on was too long).
    def text=(text)
      @text_input.text = text
      recalc # This may roll back the text if it is too long.
      publish :changed, self.text
      self.text
    end


    # @param (see Element#initialize)
    #
    # @option (see Element#initialize)
    # @option options [String] :text ("")
    # @option options [Integer] :height Sets both min and max height at once.
    # @option options [Integer] :min_height
    # @option options [Integer] :max_height (Infinite)
    # @option options [Number] :line_spacing (0)
    def initialize(options = {}, &block)
      options = {
        text: '',
        max_height: Float::INFINITY,
        line_spacing: 0,
        background_color: DEFAULT_BACKGROUND_COLOR .dup,
        border_color: DEFAULT_BORDER_COLOR.dup,
        border_color_focused: DEFAULT_BORDER_COLOR_FOCUSED.dup
      }.merge! options

      @line_spacing = options[:line_spacing]
      @border_color_focused = options[:border_color_focused]

      @lines = [''] # List of lines of wrapped text.
      @caret_positions = [[0, 0]] # [x, y] of each position the caret can be in.
      @char_widths = [] # Width of each character in the text.
      @text_input = Gosu::TextInput.new
      @old_text = ''
      @old_caret_position = 0
      @old_selection_start = 0

      @text_input.text = options[:text]

      super(options)

      min_height = (padding_y * 2) + font_size
      if options[:height]
        @max_height = @min_height = [options[:height], min_height].max
      else
        @max_height = [options[:max_height], min_height].max
        @min_height = options[:min_height] ? [options[:min_height], min_height].max : min_height
      end
      rect.height = [(padding_y * 2) + font_size, @min_height].max

      subscribe :left_mouse_button, method(:click_in_text)
      subscribe :right_mouse_button, method(:click_in_text)
    end

    # @return [nil]
    def click_in_text(sender, x, y)
      publish :focus unless focused?

      # Move caret to position the user clicks on.
      mouse_x, mouse_y = x - (self.x + padding_x), y - (self.y + padding_y)
      @char_widths.each_with_index do |width, i|
        char_x, char_y = @caret_positions[i]
        if mouse_x.between?(char_x, char_x + width) and mouse_y.between?(char_y, char_y + font_size)
          self.caret_position = @text_input.selection_start = i
          break
        end
      end

      nil
    end

    # Does the element have the focus?
    def focused?; @focused; end

    # @return [nil]
    def focus(sender)
      @focused = true
      $window.current_game_state.focus = self
      $window.text_input = @text_input

      nil
    end

    # @return [nil]
    def blur(sender)
      if focused?
        $window.current_game_state.focus = nil
        $window.text_input = nil
      end

      @focused = false

      nil
    end

    # Draw the text area.
    #
    # @return [nil]
    def draw_foreground
      # Always roll back changes made by the user unless the text is editable.
      if not editable? and text != @old_text
        @text_input.text = @old_text
        @text_input.selection_start = @old_selection_start
        self.caret_position = @old_caret_position
      else
        recalc if focused? # Workaround for Windows draw/update bug.
        @old_caret_position = caret_position
        @old_selection_start = @text_input.selection_start
      end

      # Draw the selection.
      selection_range.each do |pos|
        char_x, char_y = @caret_positions[pos]
        char_width = @char_widths[pos]
        left, top = x + padding_x + char_x, y + padding_y + char_y
        draw_rect left, top, char_width, font_size, z, SELECTION_COLOR
      end

      # Draw text.
      @lines.each_with_index do |line, index|
        font.draw(line, x + padding_x, y + padding_y + y_at_line(index), z)
      end

      # Draw the caret.
      if focused? and ((Gosu::milliseconds / CARET_PERIOD) % 2 == 0)
        caret_x, caret_y = @caret_positions[caret_position]
        left, top = x + padding_x + caret_x, y + padding_y + caret_y
        draw_rect left, top, 1, font_size, z, CARET_COLOR
      end
    end

    # y position of the
    protected
    def y_at_line(lines_number)
      lines_number * (font_size + line_spacing)
    end

    protected
    # Helper for #recalc
    # @return [Integer]
    def position_letters_in_word(word, line_width)
      word.each_char do |c|
        char_width = font.text_width(c)
        line_width += char_width
        @caret_positions.push [line_width, y_at_line(@lines.size)]
        @char_widths.push char_width
      end

      line_width
    end

    protected
    # @return [nil]
    def layout
      # Don't need to re-layout if the text hasn't changed.
      return if @old_text == text

      publish :changed, self.text

      # Save these in case we are too long.
      old_lines = @lines
      old_caret_positions = @caret_positions
      old_char_widths = @char_widths

      @lines = []
      @caret_positions = [[0, 0]] # Position 0 is before the first character.
      @char_widths = []

      space_width = font.text_width ' '
      max_width = width - padding_x * 2 - space_width

      line = ''
      line_width = 0
      word = ''
      word_width = 0

      text.each_char do |char|
        char_width = font.text_width(char)

        overall_width = line_width + (line_width == 0 ? 0 : space_width) + word_width + char_width
        if overall_width > max_width and not (char == ' ' and not word.empty?)
          if line.empty?
            # The current word is longer than the whole word, so split it.
            # Go back and set all the character positions we have.
            position_letters_in_word(word, line_width)

            # Push as much of the current word as possible as a complete line.
            @lines.push word + (char == ' ' ? '' : '-')
            line_width = font.text_width(word)

            word = ''
            word_width = 0
          else

            # Adding the current word would be too wide, so add the current line and start a new one.
            @lines.push line
            line = ''
          end

          @char_widths[-1] += (width - line_width - padding_x * 2) unless @char_widths.empty?
          line_width = 0
        end

        case char
          when "\n"
            # A new-line ends the word and puts it on the line.
            line += word
            line_width = position_letters_in_word(word, line_width)
            @caret_positions.push [line_width, y_at_line(@lines.size)]
            @char_widths[-1] += (width - line_width - padding_x * 2) unless @char_widths.empty?
            @char_widths.push 0
            @lines.push line
            word = ''
            word_width = 0
            line = ''
            line_width = 0

          when ' '
            # A space ends a word and puts it on the line.
            line += word + char
            line_width = position_letters_in_word(word, line_width)
            line_width += space_width
            @caret_positions.push [line_width, y_at_line(@lines.size)]
            @char_widths.push space_width

            word = ''
            word_width = 0

          else
            # If there was a previous line and we start a new line, put the caret pos on the current line.
            if line.empty?
              @caret_positions[-1] = [0, y_at_line(@lines.size)]
            end

            # Start building up a new word.
            word += char
            word_width += char_width
        end
      end

      # Add any remaining word on the last line.
      unless word.empty?
        position_letters_in_word(word, line_width)
        line += word
      end

      @lines.push line if @lines.empty? or not line.empty?

      # Roll back if the height is too long.
      new_height = (padding_y * 2) + y_at_line(@lines.size)
      if new_height <= max_height
        @old_text = text
        rect.height = [new_height, @min_height].max
        @old_caret_position = caret_position
        @old_selection_start = @text_input.selection_start
      else
        # Roll back!
        @lines = old_lines
        @caret_positions = old_caret_positions
        @char_widths = old_char_widths
        @text_input.text = @old_text
        self.caret_position = @old_caret_position
        @text_input.selection_start = @old_selection_start
      end

      nil
    end

    protected
    # Use block as an event handler.
    def post_init_block(&block)
      subscribe :changed, &block
    end
  end
end