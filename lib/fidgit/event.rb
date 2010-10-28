# encoding: utf-8

module Fidgit
  # Adds simple event handling methods to an object (subscribe/publish pattern).
  #
  # @example
  #   class JumpingBean
  #     include Event
  #   end
  #
  #   bean = JumpingBean.new
  #   bean.subscribe :jump do
  #     puts "Whee!"
  #   end

  #   bean.subscribe :jump do |object, direction, distance|
  #     puts "#{object.class.name} jumped #{distance} metres #{direction}"
  #   end
  #
  #   bean.publish :jump, :up, 4
  #   # Whee!
  #   # JumpingBean jumped 4 metres up
  #
  module Event
    # @overload subscribe(event, method)
    #   Add an event handler for an event, using a method.
    #   @return [nil]
    #
    # @overload subscribe(event, &block)
    #   Add an event handler for an event, using a block.
    #   @return [nil]
    def subscribe(event, method = nil, &block)
      raise ArgumentError, "Expected method or block for event handler" unless !block.nil? ^ !method.nil?
      @_event_handlers = Hash.new() { |hash, key| hash[key] = [] } unless @_event_handlers
      @_event_handlers[event].push(method ? method : block)

      nil
    end

    # Publish an event to all previously added handlers in the order they were added.
    # It will automatically call the publishing object with the method named after the event if it is defined
    # (this will be done before the manually added handlers are called).
    #
    # If any handler returns :handled, then no further handlers will be called.
    #
    # @param [Symbol] event Name of the event to publish.
    # @param [Array] args Arguments to pass to the event handlers.
    # @return [Symbol, nil] :handled if any handler handled the event or nil if none did.
    def publish(event, *args)
      if respond_to? event
        return :handled if send(event, self, *args) == :handled
      end

      if @_event_handlers
        @_event_handlers[event].each do |handler|
          return :handled if handler.call(self, *args) == :handled
        end
      end

      nil
    end
  end
end