# encoding: utf-8

module Fidgit
  class Clipboard
    # Items held in the clipboard.
    attr_reader :items

    #
    protected
    def initialize
      @items = []
    end

    # Copy items into the clipboard.
    #
    # === Parameters
    # +items+:: Items to copy [Array]
    public
    def copy(items)
      @items = items.to_a.dup

      nil
    end

    public
    def empty?
      @items.empty?
    end
  end
end