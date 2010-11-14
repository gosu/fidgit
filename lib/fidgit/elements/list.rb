# encoding: utf-8

require_relative 'container'

module Fidgit
  class List < Composite
    class Item < RadioButton
    end

    event :changed

    def size; @items.size; end
    def clear; @items.clear; end

    def initialize(options = {})
      options = {
        background_color: default(:background_color),
        border_color: default(:border_color),
      }.merge! options

      super options

      group do
        subscribe :changed do |sender, value|
          publish :changed, value
        end

        @items = pack :vertical, spacing: 0
      end
    end

    # @param [String] text
    # @option options [Gosu::Image] :icon
    def item(text, value, options = {}, &block)
      Item.new(text, value, { parent: @items }.merge!(options), &block)
    end

    protected
    def layout
      super
      if @items
        max_width = @items.each.to_a.map {|c| c.width }.max || 0
        @items.each {|c| c.rect.width = max_width }
      end

      nil
    end
  end
end