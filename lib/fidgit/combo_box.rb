# encoding: utf-8

require_relative 'button'
require_relative 'menu_pane'

module Fidgit
class ComboBox < Button
  DEFAULT_BORDER_COLOR = Gosu::Color.new(255, 255, 255)
  DEFAULT_BACKGROUND_COLOR = Gosu::Color.new(100, 100, 100)

  def index; @menu.index(@value) end
  def value; @value; end
  
  def value=(value)
    if @value != value
      @value = value
      @text = @menu.find(@value).text
      publish :changed, @value
    end

    value
  end

  def index=(index)
    if index.between?(0, @menu.size - 1)
      self.value = @menu[index].value
    end

    index
  end

  # @param (see Button#initialize)
  # @option (see Button#initialize)
  # @option options [] :value
  def initialize(parent, options = {}, &block)
    options = {
      border_color: DEFAULT_BORDER_COLOR,
      background_color: DEFAULT_BACKGROUND_COLOR
    }.merge! options

    @value = options[:value]
    
    @hover_index = 0

    @menu = MenuPane.new do
      subscribe :selected do |widget, value|
        self.value = value
      end
    end

    super(parent, options)

    rect.height = [height, font_size + padding_y * 2].max
    rect.width = [width, font_size * 4 + padding_x * 2].max
  end

  def item(*args)
    @menu.add_item(*args)

    # Force text to be updated.
    if item = @menu.find(@value)
      @text = item.text
    end

    nil
  end

  def clicked_left_mouse_button(sender, x, y)
    @menu.x = self.x
    @menu.y = self.y + height + 1
    $window.game_state_manager.current_game_state.show_menu @menu

    nil
  end
end
end