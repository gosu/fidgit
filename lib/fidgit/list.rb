# encoding: utf-8

require_relative 'container'

module Fidgit
  class List < Composite
    # @private
    class Item < Button
      class Group < RadioButton::Group
      end
      # TODO: Need to inherit from RadioButton, but it doesn't display anything.
    end

    DEFAULT_BACKGROUND_COLOR = Gosu::Color.rgb(200, 200, 200)
    DEFAULT_BORDER_COLOR = Gosu::Color.rgb(255, 255, 255)

    def size; @items.size; end
    def clear; @items.clear; end

    def initialize(parent, options = {})
      options = {
        background_color: DEFAULT_BACKGROUND_COLOR,
        border_color: DEFAULT_BORDER_COLOR,
      }.merge! options

      super parent, options

      Item::Group.new(self) do |group|
        group.subscribe :changed do |sender, value|
          publish :changed, value
        end

        @items = group.pack :vertical, spacing: 0
      end
    end

    # @param [String] text
    # @option options [Gosu::Image] :icon
    def item(options = {})
      Item.new(@items, options)
    end
  end
end