# encoding: utf-8

require_relative 'button'

module Fidgit
  class RadioButton < Button
    DEFAULT_BORDER_COLOR_CHECKED = Gosu::Color.new(255, 0, 255)
    DEFAULT_BORDER_COLOR_UNCHECKED = Gosu::Color.new(50, 50, 50)

    attr_reader :group, :value

    handles :changed
    handles :checked
    handles :unchecked

    def checked?; @checked; end

    # @param (see Button#initialize)
    # @param [Object] value
    #
    # @option (see Button#initialize)
    # @option options [Boolean] :checked
    def initialize(text, value, options = {}, &block)
      options = {
        checked: false,
        border_color_checked: DEFAULT_BORDER_COLOR_CHECKED,
        border_color_unchecked: DEFAULT_BORDER_COLOR_UNCHECKED
      }.merge! options

      @checked = options[:checked]
      @value = value

      super(text, options)

      @border_color_checked = (options[:border_color_checked] || @border_color).dup
      @border_color_unchecked = (options[:border_color_unchecked] || @border_color).dup
      add_to_group

      @border_color = (checked? ? @border_color_checked : @border_color_unchecked).dup
    end

    def clicked_left_mouse_button(sender, x, y)
      super
      check
      nil
    end

    # Check the button and update its group. This may uncheck another button in the group if one is selected.
    def check
      return if checked?

      @checked = true
      @group.value = value
      @border_color = @border_color_checked.dup
      publish :changed, @checked
      publish :checked

      nil
    end

    # Uncheck the button and update its group.
    def uncheck
      return unless checked?

      @checked = false
      @group.value = value
      @border_color = @border_color_unchecked.dup
      publish :changed, @checked
      publish :unchecked

      nil
    end

    protected
    def parent=(parent)
      @group.remove_button self if @parent
      super(parent)
      add_to_group if parent
      parent
    end

    protected
    def add_to_group
      container = parent
      while container and not container.is_a? Group
        container = container.parent
      end

      raise "#{self.class.name} must be placed inside a group element" unless container

      @group = container
      @group.add_button self
      nil
    end
  end
end