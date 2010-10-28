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

      @mouse_x, @mouse_y = 0, 0
      @focus = nil

      @@draw_pixel ||= Gosu::Image.new($window, PIXEL_IMAGE, true) # Must be tileable or it will blur.

      super()
      add_inputs *DEFAULT_INPUTS
    end

    def setup
      @mouse_over = nil # Element the mouse is hovering over.
      @mouse_moved_at = Gosu::milliseconds
    end

    # Internationalisation helper.
    def t(*args); I18n.t(*args); end

    def update
      x, y = $window.mouse_x, $window.mouse_y

      new_mouse_over = @outer_container.hit_element(x, y)

      if new_mouse_over
        new_mouse_over.publish :enter if new_mouse_over != @mouse_over
        new_mouse_over.publish :hover, x, y
      end

      @mouse_over.publish :leave if @mouse_over and new_mouse_over != @mouse_over

      @mouse_over = new_mouse_over

      # Check if the mouse has moved, and no menu is shown, so we can show a tooltip.
      if [x, y] == [@mouse_x, @mouse_y] and (not @menu)
        if @mouse_over and (Gosu::milliseconds - @mouse_moved_at) > tool_tip_delay
          if text = @mouse_over.tip and not text.empty?
            @tool_tip ||= ToolTip.new(nil)
            @tool_tip.text = text
            @outer_container.add @tool_tip
            @tool_tip.x = $window.cursor.x
            @tool_tip.y = $window.cursor.y + $window.cursor.height # Place the tip beneath the cursor.
          else
            clear_tip
          end
        end
      else
        clear_tip
        @mouse_moved_at = Gosu::milliseconds
      end

      @mouse_x, @mouse_y = x, y

      @outer_container.update

      super
    end

    def draw
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
        @mouse_over.publish :left_mouse_button, @mouse_x, @mouse_y
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
        @mouse_over.publish :released_left_mouse_button, @mouse_x, @mouse_y
        @mouse_over.publish :clicked_left_mouse_button, @mouse_x, @mouse_y if @mouse_over == @mouse_down_on
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
      @mouse_moved_at = Gosu::milliseconds

      nil
    end
  end
end