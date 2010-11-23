# encoding: utf-8

require_relative 'button'
require_relative 'menu_pane'

module Fidgit
class ComboBox < Button
  event :changed

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
  def initialize(options = {}, &block)
    options = {
      background_color: default(:background_color),
      border_color: default(:border_color),
    }.merge! options

    @value = options[:value]
    
    @hover_index = 0

    @menu = MenuPane.new(show: false) do
      subscribe :selected do |widget, value|
        self.value = value
      end
    end

    super('', options)

    rect.height = [height, font_size + padding_top + padding_bottom].max
    rect.width = [width, font_size * 4 + padding_left + padding_right].max
  end

  def item(text, value, options = {}, &block)
    item = @menu.item(text, value, options, &block)

    # Force text to be updated if the item added has the same value.
    if item.value == @value
      @text = item.text
    end

    item
  end

  def clicked_left_mouse_button(sender, x, y)
    @menu.x = self.x
    @menu.y = self.y + height + border_thickness
    $window.game_state_manager.current_game_state.show_menu @menu

    nil
  end

  protected
  # Any combo-box passed a block will allow you access to its methods.
  def post_init_block(&block)
      case block.arity
        when 1
          yield self
        when 0
          instance_methods_eval &block
        else
          raise "block arity must be 0 or 1"
      end
  end
end
end