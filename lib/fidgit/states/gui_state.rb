# encoding: utf-8

module Fidgit
  class GuiState < Chingu::GameState
    # A 1x1 white pixel used for drawing.
    PIXEL_IMAGE = 'pixel.png'

    # The Container that contains all the elements for this GuiState.
    # @return [Packer]
    attr_reader :container

    # The element with focus.
    # @return [Element]
    attr_reader :focus

    # The Cursor.
    # @return [Cursor]
    def cursor; @@cursor; end

    # Sets the focus to a particular element.
    def focus=(element)
      @focus.publish :blur if @focus and element
      @focus = element
    end

    # Delay, in ms, before a tool-tip will appear.
    def tool_tip_delay
      500 # TODO: configure this.
    end

    # Show a file_dialog.
    # (see FileDialog#initialize)
    def file_dialog(type, options = {}, &block)
      FileDialog.new(type, options, &block)
    end

    # (see MenuPane#initialize)
    def menu(options = {}, &block); MenuPane.new(options, &block); end

    # (see MessageDialog#initialize)
    def message(text, options = {}, &block); MessageDialog.new(text, options, &block); end

    # (see Container#pack)
    def pack(*args, &block); @container.pack *args, &block; end

    # (see Container#clear)
    def clear(*args, &block); @container.clear *args, &block; end

    def initialize
      # The container is where the user puts their content.
      @container = VerticalPacker.new(padding: 0, width: $window.width, height: $window.height)

      @focus = nil

      unless defined? @@draw_pixel
        media_dir = File.expand_path(File.join(File.dirname(__FILE__), '..', '..', '..', 'media'))
        Gosu::Image.autoload_dirs << File.join(media_dir, 'images')
        Gosu::Sample.autoload_dirs << File.join(media_dir, 'sounds')

        @@draw_pixel = Gosu::Image.new($window, File.join(media_dir, 'images', PIXEL_IMAGE), true) # Must be tileable or it will blur.
        @@cursor = Cursor.new
      end

      @mouse_over = nil # Element the mouse is hovering over.
      @mouse_down_on = Hash.new # Element that each button was pressed over.
      @mouse_down_pos = Hash.new # Position that each button was pressed down at.
      @drag_button = nil

      @min_drag_distance = 0

      @@mouse_moved_at = Gosu::milliseconds

      super()

      add_inputs(
        left_mouse_button: ->{ redirect_mouse_button(:left) },
        holding_left_mouse_button: ->{ redirect_holding_mouse_button(:left) },
        released_left_mouse_button: ->{ redirect_released_mouse_button(:left) },
        
        middle_mouse_button: ->{ redirect_mouse_button(:middle) },
        holding_middle_mouse_button: ->{ redirect_holding_mouse_button(:middle) },
        released_middle_mouse_button: ->{ redirect_released_mouse_button(:middle) },
  
        right_mouse_button: ->{ redirect_mouse_button(:right) },
        holding_right_mouse_button: ->{ redirect_holding_mouse_button(:right) },
        released_right_mouse_button: ->{ redirect_released_mouse_button(:right) },
  
        mouse_wheel_up: :redirect_mouse_wheel_up,
        mouse_wheel_down: :redirect_mouse_wheel_down
      )
    end

    # Internationalisation helper.
    def t(*args); I18n.t(*args); end

    def update
      cursor.update
      @tool_tip.update if @tool_tip
      @menu.update if @menu
      @container.update

      # Check menu first, then other elements.
      new_mouse_over = @menu.hit_element(cursor.x, cursor.y) if @menu
      new_mouse_over = @container.hit_element(cursor.x, cursor.y) unless new_mouse_over

      if new_mouse_over
        new_mouse_over.publish :enter if new_mouse_over != @mouse_over
        new_mouse_over.publish :hover, cursor.x, cursor.y
      end

      @mouse_over.publish :leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      # Check if the mouse has moved, and no menu is shown, so we can show a tooltip.
      if [cursor.x, cursor.y] == @last_cursor_pos and (not @menu)
        if @mouse_over and (Gosu::milliseconds - @@mouse_moved_at) > tool_tip_delay
          if text = @mouse_over.tip and not text.empty?
            @tool_tip ||= ToolTip.new
            @tool_tip.text = text
            @tool_tip.x = cursor.x
            @tool_tip.y = cursor.y + cursor.height # Place the tip beneath the cursor.
          else
            clear_tip
            @@mouse_moved_at = Gosu::milliseconds
          end
        end
      else
        clear_tip
        @@mouse_moved_at = Gosu::milliseconds
      end

      # The element that grabs input.
      @active_element = @dragging_element || @focus || @mouse_over

      @last_cursor_pos = [cursor.x, cursor.y]

      super
    end

    def draw
      @container.draw
      @menu.draw if @menu
      @tool_tip.draw if @tool_tip
      cursor.draw

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

      nil
    end

    # Hides the currently shown menu, if any.
    # @return nil
    def hide_menu
      @menu = nil

      nil
    end

    # Flush all pending drawing to the screen.
    def flush
      $window.flush
    end

    # Draw a filled rectangle.
    def draw_rect(x, y, width, height, z, color, mode = :default)
      @@draw_pixel.draw x, y, z, width, height, color, mode

      nil
    end

    # Draw an unfilled rectangle.
    def draw_frame(x, y, width, height, z, color, mode = :default)
      draw_rect(x, y + 1, 1, height - 2, z, color, mode) # left
      draw_rect(x, y, width, 1, z, color, mode) # top
      draw_rect(x + width - 1, y + 1, 1, height - 1, z, color, mode) # right
      draw_rect(x, y + height - 1, width, 1, z, color, mode) # bottom

      nil
    end

    def distance(x1, y1, x2, y2)
      Gosu.distance(x1, y1, x2, y2)
    end

    protected
    def redirect_mouse_button(button)
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      hide_menu unless @menu and @menu == @mouse_over

      # Blur if clicking outside the focused element.
      if @focus and @mouse_over != @focus
        @focus.publish :blur
        @focus = nil
      end

      # Publish :left_mouse_button for the element that is clicked.
      if @mouse_over
        @mouse_down_pos[button] = [cursor.x, cursor.y]
        @mouse_down_on[button] = @mouse_over
        @mouse_over.publish :"#{button}_mouse_button", *@mouse_down_pos[button]
      else
        @mouse_down_pos[button] = nil
        @mouse_down_on[button] = nil
      end

      nil
    end

    protected
    def redirect_released_mouse_button(button)
      # Ensure that if the user clicks away from a menu, it is automatically closed.
      hide_menu if @menu and @mouse_over != @menu

      if @mouse_over
        @mouse_over.publish :"released_#{button}_mouse_button", cursor.x, cursor.y
        @mouse_over.publish :"clicked_#{button}_mouse_button", cursor.x, cursor.y if @mouse_over == @mouse_down_on[button]
      end

      if @dragging_element and @drag_button == button
        @dragging_element.publish :end_drag, cursor.x, cursor.y, @drag_button, @mouse_over
        @dragging_element = nil
        @drag_button = nil
      end

      @mouse_down_on[button] = nil
      @mouse_down_pos[button] = nil

      nil
    end

    protected
    def redirect_holding_mouse_button(button)
      if not @dragging_element and @mouse_down_on[button] and @mouse_down_on[button].drag?(button) and
          distance(*@mouse_down_pos[button], cursor.x, cursor.y) > @min_drag_distance
        @drag_button = button
        @dragging_element = @mouse_down_on[button]
        @dragging_element.publish :begin_drag, *@mouse_down_pos[button], :left
      end

      if @dragging_element
        if @drag_button == button
          @dragging_element.publish :update_drag, cursor.x, cursor.y
        end
      else
        @mouse_over.publish :"holding_#{button}_mouse_button", cursor.x, cursor.y if @mouse_over
      end

      nil
    end

    protected
    def redirect_mouse_wheel_up
      @active_element.publish :mouse_wheel_up, cursor.x, cursor.y if @active_element
      nil
    end

    protected
    def redirect_mouse_wheel_down
      @active_element.publish :mouse_wheel_down, cursor.x, cursor.y if @active_element
      nil
    end

    protected
    # Hide the tool-tip, if any.
    def clear_tip
      @@mouse_moved_at = Gosu::milliseconds
      @tool_tip = nil

      nil
    end
  end
end