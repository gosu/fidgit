# encoding: utf-8

module Fidgit
  class GuiState < Chingu::GameState
    # A 1x1 white pixel used for drawing.
    PIXEL_IMAGE = File.join(File.dirname(__FILE__), '..', '..', 'media', 'images', 'pixel.png')

    DEFAULT_INPUTS = [
      :left_mouse_button, :right_mouse_button,
      :holding_left_mouse_button, :holding_right_mouse_button,
      :released_left_mouse_button, :released_right_mouse_button,
      :mouse_wheel_up, :mouse_wheel_down,
    ]

    attr_reader :container
    attr_reader :focus

    def cursor; @@cursor; end

    # Will implement these later.
    DEFAULT_INPUTS.each do |handler|
      define_method handler do
        nil
      end
      private handler
    end

    def focus=(focus)
      @focus.publish :blur if @focus and focus
      @focus = focus
    end

    def tool_tip_delay
      500 # TODO: configure this.
    end

    def initialize
      @outer_container = Container.new(nil) do |container|
        @container = Container.new(container)
      end

      @focus = nil

      unless defined? @@draw_pixel
        media_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', 'media'))
        Gosu::Image.autoload_dirs << File.join(media_dir, 'images')
        Gosu::Sample.autoload_dirs << File.join(media_dir, 'sounds')

        @@draw_pixel = Gosu::Image.new($window, PIXEL_IMAGE, true) # Must be tileable or it will blur.
        @@cursor = Cursor.new
      end

      @mouse_over = nil # Element the mouse is hovering over.
      @@mouse_moved_at = Gosu::milliseconds

      super()
      add_inputs *DEFAULT_INPUTS
    end

    # Internationalisation helper.
    def t(*args); I18n.t(*args); end

    def update
      cursor.update

      new_mouse_over = @outer_container.hit_element(cursor.x, cursor.y)

      if new_mouse_over
        new_mouse_over.publish :enter if new_mouse_over != @mouse_over
        new_mouse_over.publish :hover, cursor.x, cursor.y
      end

      @mouse_over.publish :leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      # Check if the mouse has moved, and no menu is shown, so we can show a tooltip.
      if [cursor.x, cursor.y] == [@last_cursor_x, @last_cursor_y] and (not @menu)
        if @mouse_over and (Gosu::milliseconds - @@mouse_moved_at) > tool_tip_delay
          if text = @mouse_over.tip and not text.empty?
            @tool_tip ||= ToolTip.new(nil)
            @tool_tip.text = text
            @outer_container.add @tool_tip
            @tool_tip.x = cursor.x
            @tool_tip.y = cursor.y + cursor.height # Place the tip beneath the cursor.
          else
            clear_tip
          end
        end
      else
        clear_tip
        @@mouse_moved_at = Gosu::milliseconds
      end

      @outer_container.update

      @last_cursor_x, @last_cursor_y = cursor.x, cursor.y

      super
    end

    def draw
      cursor.draw
      @outer_container.draw

      nil
    end

    def finalize
      clear_tip

      nil
    end

    # Set the menu pane to be displayed.
    #
    # @param [MenuPane] menu Menu to display.
    # @return nil
    def show_menu(menu)
      hide_menu if @menu
      @menu = menu
      @outer_container.add @menu

      nil
    end

    # @return nil
    def hide_menu
      @outer_container.remove @menu if @menu
      @menu = nil

      nil
    end

    def left_mouse_button
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      hide_menu unless @menu and @menu == @mouse_over

      if @focus and @mouse_over != @focus
        @focus.publish :blur
        @focus = nil
      end

      if @mouse_over
        @mouse_over.publish :left_mouse_button, cursor.x, cursor.y
        @mouse_down_on = @mouse_over
      else
        @mouse_down_on = nil
      end

      nil
    end

    def released_left_mouse_button
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      hide_menu if @menu and @mouse_over != @menu

      if @mouse_over
        @mouse_over.publish :released_left_mouse_button, cursor.x, cursor.y
        @mouse_over.publish :clicked_left_mouse_button, cursor.x, cursor.y if @mouse_over == @mouse_down_on
      end

      nil
    end

    def flush
      $window.flush
    end

    def draw_rect(x, y, width, height, z, color, mode = :default)
      @@draw_pixel.draw x, y, z, width, height, color, mode

      nil
    end

    def draw_frame(x, y, width, height, z, color, mode = :default)
      draw_rect(x, y, 1, height, z, color, mode) # left
      draw_rect(x, y, width, 1, z, color, mode) # top
      draw_rect(x + width - 1, y, 1, height, z, color, mode) # right
      draw_rect(x, y + height - 1, width, 1, z, color, mode) # bottom

      nil
    end

    # Hide the tool-tip, if any.
    protected
    def clear_tip
      @outer_container.remove @tool_tip if @tool_tip
      @tool_tip = nil
      @@mouse_moved_at = Gosu::milliseconds

      nil
    end
  end
end