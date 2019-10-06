module Fidgit
  class TextArea < Element
    TAGS_PATTERN = %r%<[a-z](?:=[a-f0-9]+)?>|</[a-z]>%i

    # @return [Number]
    attr_reader :min_height
    # @return [Number]
    attr_reader :max_height

    # @return [Number]
    attr_reader :line_spacing

    # @param [Boolean] value
    # @return [Boolean]
    attr_writer :editable

    # @return [String] Text, but stripped of tags.
    attr_reader :stripped_text

    event :begin_drag
    event :update_drag
    event :end_drag

    event :changed
    event :focus
    event :blur

    def drag?(button); button == :left; end

    # Is the area editable? This will always be false if the Element is disabled.
    def editable?
      enabled? and @editable
    end

    # Text within the element.
    # @return [String]
    def text
      @text_input.text.force_encoding '-8'
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
      stripped_text[selection_range]
    end

    # Sets the text within the selection. The caret will be placed at the end of the inserted text.
    #
    # @param [String] str Text to insert.
    # @return [String] The new selection text.
    def selection_text=(str)
      from = [@text_input.selection_start, @text_input.caret_pos].min
      to = [@text_input.selection_start, @text_input.caret_pos].max
      new_length = str.length

      full_text = text
      tags_length_before = (0...from).inject(0) {|m, i| m + @tags[i].length }
      tags_length_inside = (from...to).inject(0) {|m, i| m + @tags[i].length }
      range = (selection_range.first + tags_length_before)...(selection_range.last + tags_length_before + tags_length_inside)
      full_text[range] = str.encode('-8', undef: :replace)
      @text_input.text = full_text

      @text_input.selection_start = @text_input.caret_pos = from + new_length

      recalc # This may roll back the text if it is too long!

      publish :changed, self.text

      str
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
      raise ArgumentError, "Caret position must be in the range 0 to the length of the text (inclusive)" unless position.between?(0, stripped_text.length)
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
    # @option options [Boolean] :editable (true)
    def initialize(options = {}, &block)
      options = {
        text: '',
        max_height: Float::INFINITY,
        line_spacing: default(:line_spacing),
        background_color: default(:background_color),
        border_color: default(:border_color),
        caret_color: default(:caret_color),
        caret_period: default(:caret_period),
        focused_border_color: default(:focused, :border_color),
        selection_color: default(:selection_color),
        editable: true,
      }.merge! options

      @line_spacing = options[:line_spacing]
      @caret_color = options[:caret_color].dup
      @caret_period = options[:caret_period]
      @focused_border_color = options[:focused_border_color].dup
      @selection_color = options[:selection_color].dup
      @editable = options[:editable]

      @lines = [''] # List of lines of wrapped text.
      @caret_positions = [[0, 0]] # [x, y] of each position the caret can be in.
      @char_widths = [] # Width of each character in the text.
      @text_input = Gosu::TextInput.new
      @old_text = ''
      @old_caret_position = 0
      @old_selection_start = 0
      @tags = Hash.new("") # Hash of tags embedded in the text.

      @text_input.text = options[:text].dup
      @stripped_text = '' # Text stripped of xml tags.

      super(options)

      min_height = padding_left + padding_right + font.height
      if options[:height]
        @max_height = @min_height = [options[:height], min_height].max
      else
        @max_height = [options[:max_height], min_height].max
        @min_height = options[:min_height] ? [options[:min_height], min_height].max : min_height
      end
      rect.height = [padding_left + padding_right + font.height, @min_height].max

      subscribe :left_mouse_button, method(:click_in_text)
      subscribe :right_mouse_button, method(:click_in_text)

      # Handle dragging.
      subscribe :begin_drag do |sender, x, y|
        # Store position of the handle when it starts to drag.
        @drag_start_pos = [x - self.x, y - self.y]
      end

      subscribe :update_drag do |sender, x, y|
        index = text_index_at_position(x, y)
        self.caret_position = [index, @stripped_text.length].min if index
      end

      subscribe :end_drag do
        @drag_start_pos = nil
      end
    end

    # @return [nil]
    def click_in_text(sender, x, y)
      publish :focus unless focused?

      # Move caret to position the user clicks on.
      index = text_index_at_position x, y
      self.caret_position = @text_input.selection_start = [index, @stripped_text.length].min if index

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
      if editable? or text == @old_text
        recalc if focused? # Workaround for Windows draw/update bug.
        @old_caret_position = caret_position
        @old_selection_start = @text_input.selection_start
      else
        roll_back
      end

      if caret_position > stripped_text.length
        self.caret_position = stripped_text.length
      end

      if @text_input.selection_start >= stripped_text.length
        @text_input.selection_start = stripped_text.length
      end

      # Draw the selection.
      selection_range.each do |pos|
        char_x, char_y = @caret_positions[pos]
        char_width = @char_widths[pos]
        left, top = x + padding_left + char_x, y + padding_top + char_y
        draw_rect left, top, char_width, font.height, z, @selection_color
      end

      # Draw text.
      @lines.each_with_index do |line, index|
        font.draw(line, x + padding_left, y + padding_top + y_at_line(index), z)
      end

      # Draw the caret.
      if focused? and ((Gosu::milliseconds / @caret_period) % 2 == 0)
        caret_x, caret_y = @caret_positions[caret_position]
        left, top = x + padding_left + caret_x, y + padding_top + caret_y
        draw_rect left, top, 1, font.height, z, @caret_color
      end
    end

    protected
    # Index of character in reference to the displayable text.
    def text_index_at_position(x, y)
      # Move caret to position the user clicks on.
      mouse_x, mouse_y = x - (self.x + padding_left), y - (self.y + padding_top)
      @char_widths.each.with_index do |width, i|
        char_x, char_y = @caret_positions[i]
        if mouse_x.between?(char_x, char_x + width) and mouse_y.between?(char_y, char_y + font.height)
          return i
        end
      end

      nil # Didn't find a character at that position.
    end

    # y position of the
    protected
    def y_at_line(lines_number)
      lines_number * (font.height + line_spacing)
    end


    protected
    # Helper for #recalc
    # @return [Integer]
    def position_letters_in_word(word, line_width)
      # Strip tags before measuring word.
      word.gsub(ENTITIES_AND_TAGS_PATTERN, '').each_char do |c|
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
      max_width = width - padding_left - padding_right - space_width

      line = ''
      line_width = 0
      word = ''
      word_width = 0

      strip_tags

      stripped_text.each_char.with_index do |char, i|
        tag = @tags[i]

        case char
          when "\n"
            char_width = 0
          else
            char_width = font.text_width char
        end

        overall_width = line_width + (line_width == 0 ? 0 : space_width) + word_width + char_width
        if overall_width > max_width and not (char == ' ' and not word.empty?)
          if line.empty?
            # The current word is longer than the whole word, so split it.
            # Go back and set all the character positions we have.
            position_letters_in_word(word, line_width)

            # Push as much of the current word as possible as a complete line.
            @lines.push word + tag + (char == ' ' ? '' : '-')
            line_width = font.text_width(word)

            word = ''
            word_width = 0
          else

            # Adding the current word would be too wide, so add the current line and start a new one.
            @lines.push line
            line = ''
          end

          widen_last_character line_width
          line_width = 0
        end

        case char
          when "\n"
            # A new-line ends the word and puts it on the line.
            line += word + tag
            line_width = position_letters_in_word(word, line_width)
            @caret_positions.push [line_width, y_at_line(@lines.size)]
            @char_widths.push 0
            widen_last_character line_width
            @lines.push line
            word = ''
            word_width = 0
            line = ''
            line_width = 0

          when ' '
            # A space ends a word and puts it on the line.
            line += word + tag + char
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
            word += tag + char
            word_width += char_width
        end
      end

      # Add any remaining word on the last line.
      unless word.empty?
        line_width = position_letters_in_word(word, line_width)
        @char_widths << width - line_width - padding_left - padding_right
        line += word
      end

      @lines.push line if @lines.empty? or not line.empty?

      # Roll back if the height is too long.
      new_height = padding_left + padding_right + y_at_line(@lines.size)
      if new_height <= max_height
        @old_text = text
        rect.height = [new_height, @min_height].max
        @old_caret_position = caret_position
        @old_selection_start = @text_input.selection_start
      else
        roll_back
      end

      nil
    end

    protected
    def roll_back
      @text_input.text = @old_text
      self.caret_position = @old_caret_position
      @text_input.selection_start = @old_selection_start
      recalc
    end

    protected
    def widen_last_character(line_width)
      @char_widths[-1] += (width - line_width - padding_left - padding_right) unless @char_widths.empty?
    end

    public
    # Cut the selection and copy it to the clipboard.
    def cut
      str = selection_text
      unless str.empty?
        Clipboard.copy str
        self.selection_text = '' if editable?
      end
    end

    public
    # Copy the selection to the clipboard.
    def copy
      str = selection_text
      Clipboard.copy str unless str.empty?
    end

    public
    # Paste the contents of the clipboard into the TextArea.
    def paste
      self.selection_text = Clipboard.paste
    end

    protected
    # Use block as an event handler.
    def post_init_block(&block)
      subscribe :changed, &block
    end

    protected
    # Strip XML tags ("<c=000000></c>")
    def strip_tags
      tags_length = 0
      @tags = Hash.new('')

      @stripped_text = text.gsub(TAGS_PATTERN) do |tag|
        pos = $`.length - tags_length
        tags_length += tag.length
        @tags[pos] += tag
      end
    end
  end
end