# encoding: utf-8

module Fidgit
  class RadioButton < Button
    attr_reader :group, :value

    event :changed

    def checked?; @checked; end

    # @param (see Button#initialize)
    # @param [Object] value
    #
    # @option (see Button#initialize)
    # @option options [Boolean] :checked
    def initialize(text, value, options = {}, &block)
      options = {
        checked: false,
        checked_border_color: default(:checked, :border_color),
      }.merge! options

      @checked = options[:checked]
      @value = value

      super(text, options)

      @checked_border_color = options[:checked_border_color].dup
      @unchecked_border_color = border_color
      add_to_group

      @border_color = (checked? ? @checked_border_color : @unchecked_border_color).dup
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
      @border_color = @checked_border_color.dup
      publish :changed, @checked

      nil
    end

    # Uncheck the button and update its group.
    def uncheck
      return unless checked?

      @checked = false
      @group.value = value
      @border_color = @unchecked_border_color.dup
      publish :changed, @checked

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