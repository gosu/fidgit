require 'forwardable'

module Fidgit
class ComboBox < Button
  extend Forwardable

  ARROW_IMAGE = "combo_arrow.png"

  def_delegators :@menu, :each

  event :changed

  def index; @menu.index(@value) end
  def value; @value; end
  
  def value=(value)
    if @value != value
      @value = value
      item = @menu.find(@value)
      self.text = item.text
      self.icon = item.icon
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

    @@arrow ||= Gosu::Image[ARROW_IMAGE]

    super('', options)

    rect.height = [height, font.height + padding_top + padding_bottom].max
    rect.width = [width, font.height * 4 + padding_left + padding_right].max
  end

  def item(text, value, options = {}, &block)
    item = @menu.item(text, value, options, &block)

    # Force text to be updated if the item added has the same value.
    if item.value == @value
      self.text = item.text
      self.icon = item.icon
    end

    recalc

    item
  end

  def draw
    super
    size = height / @@arrow.width.to_f
    @@arrow.draw x + width - height, y, z, size, size
  end

  def clicked_left_mouse_button(sender, x, y)
    @menu.x = self.x
    @menu.y = self.y + height + border_thickness
    $window.game_state_manager.current_game_state.show_menu @menu

    nil
  end

  def clear
    self.text = ""
    self.icon = nil
    @menu.clear
  end

  protected
  def layout
    super

    # Max width of all items + allow size for the arrow.
    rect.width = [@menu.width + height, min_width].max

    nil
  end


  protected
  # Any combo-box passed a block will allow you access to its methods.
  def post_init_block(&block)
    with(&block)
  end
end
end