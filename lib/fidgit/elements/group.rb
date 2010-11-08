 module Fidgit
   class Group < Packer
    attr_reader :selected

    handles :changed

    def value; @selected ? @selected.value : nil; end

    # @example
    #   group do
    #     pack :horizontal do
    #       radio_button 1, text: '1', checked: true
    #       radio_button 2, text: '2'
    #       subscribe :changed do |sender, value|
    #         puts value
    #       end
    #     end
    #   end
    #
    # @param (see Packer#initialize)
    #
    # @option (see Packer#initialize)
    def initialize(parent, options = {}, &block)
      options = {
        padding_x: 0,
        padding_y: 0
      }.merge! options

      super(parent, options)

      @selected = nil
      @buttons = []
    end

    def add_button(button)
      @buttons.push button
      button_checked button if button.checked?

      nil
    end

    # @example
    #   @my_group = group do
    #     pack :horizontal do
    #       radio_button(1, text: '1', checked: true)
    #       radio_button(2, text: '2')
    #     end
    #    end
    #
    #   # later
    #   @my_group.value = 2
    def value=(value)
      if value != self.value
        button = @buttons.find { |b| b.value == value }
        @selected.uncheck if @selected and @selected.checked?
        @selected = button
        @selected.check if @selected and not @selected.checked?
        publish :changed, self.value
      end

      value
    end
  end
end
