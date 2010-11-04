# encoding: utf-8

require_relative 'container'

module Fidgit
  class List < Composite
    # @private
    class Item < RadioButton
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

      group do
        subscribe :changed do |sender, value|
          publish :changed, value
        end

        @items = pack :vertical, spacing: 0
      end
    end

    # @param [String] text
    # @option options [Gosu::Image] :icon
    def item(value, options = {}, &block)
      Item.new(@items, value, options, &block)
    end
  end
end