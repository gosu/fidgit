# encoding: utf-8

module Fidgit
  class Clipboard
    # Items held in the clipboard.
    attr_reader :items

    def empty?; @items.empty?; end

    def initialize
      @items = []
    end

    # Copy items into the clipboard.
    #
    # @param [Array] items Items to copy
    def copy(items)
      @items = items.to_a.dup

      nil
    end
  end
end