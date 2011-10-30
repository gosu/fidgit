# encoding: utf-8

module Fidgit
  # Manages a history of actions, along with doing, undoing and redoing those actions.
  class History
    # Maximum number of actions in the History before Actions are deleted.
    DEFAULT_MAX_SIZE = 250

    # An action in the History. Inherit actions from this in order to add them to a History.
    class Action
      # Perform the action.
      def do; raise NotImplementedError, "#{self.class} does not have a do method defined"; end

      # Reverse the action.
      def undo; raise NotImplementedError, "#{self.class} does not have an undo method defined"; end
    end

    # Is there an action that can be undone?
    def can_undo?; @last_done >= 0; end

    # Is there an action that has been undone that can now be redone?
    def can_redo?; @last_done < (@actions.size - 1); end

    def initialize(max_size = DEFAULT_MAX_SIZE)
      @max_size = max_size
      @actions = []
      @last_done = -1 # Last command that was performed.
    end

    # Perform a History::Action, adding it to the history.
    # If there are currently any actions that have been undone, they will be permanently lost and cannot be redone.
    #
    # @param [History::Action] action Action to be performed
    def do(action)
      raise ArgumentError, "Parameter, 'action', expected to be a #{Action}, but received: #{action}" unless action.is_a? Action

      # Remove all undone actions when a new one is performed.
      if can_redo?
        if @last_done == -1
          @actions.clear
        else
          @actions = @actions[0..@last_done]
        end
      end

      # If history is too big, remove the oldest action.
      if @actions.size >= @max_size
        @actions.shift
      end

      @last_done = @actions.size
      @actions << action
      action.do

      nil
    end

    # Perform a History::Action, replacing the last action that was performed.
    #
    # @param [History::Action] action Action to be performed
    def replace_last(action)
      raise ArgumentError, "Parameter, 'action', expected to be a #{Action}, but received: #{action}" unless action.is_a? Action

      @actions[@last_done].undo
      @actions[@last_done] = action
      action.do

      nil
    end

    # Undo the last action that was performed.
    def undo
      raise "Can't undo unless there are commands in past" unless can_undo?

      @actions[@last_done].undo
      @last_done -= 1

      nil
    end

    # Redo the last action that was undone.
    def redo
      raise "Can't redo if there are no commands in the future" unless can_redo?

      @last_done += 1
      @actions[@last_done].do

      nil
    end
  end
end