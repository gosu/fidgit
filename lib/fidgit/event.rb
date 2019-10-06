module Fidgit
  # Adds simple event handling methods to an object (subscribe/publish pattern).
  #
  # @example
  #   class JumpingBean
  #     include Event
  #     event :jump
  #   end
  #
  #   bean = JumpingBean.new
  #   bean.subscribe :jump do
  #     puts "Whee!"
  #   end
  #
  #   bean.subscribe :jump do |object, direction, distance|
  #     puts "#{object.class.name} jumped #{distance} metres #{direction}"
  #   end
  #
  #   bean.publish :jump, :up, 4
  #   # Whee!
  #   # JumpingBean jumped 4 metres up
  #
  module Event
    # Created and returned by {Event#subscribe} and can be used to unsubscribe from the event.
    class Subscription
      attr_reader :publisher, :event, :handler

      def initialize(publisher, event, handler)
        raise TypeError unless publisher.is_a? Event
        raise TypeError unless event.is_a? Symbol
        raise TypeError unless handler.is_a? Proc or handler.is_a? Method

        @publisher, @event, @handler = publisher, event, handler
      end

      def unsubscribe
        @publisher.unsubscribe self
      end
    end

    class << self
      def new_event_handlers
        # Don't use Set, since it is not guaranteed to be ordered.
        Hash.new {|h, k| h[k] = [] }
      end
    end

    # @return [Subscription] Definition of this the handler created by this subscription, to be used with {#unsubscribe}
    def subscribe(event, method = nil, &block)
      raise ArgumentError, "Expected method or block for event handler" unless !block.nil? ^ !method.nil?
      raise ArgumentError, "#{self.class} does not handle #{event.inspect}" unless events.include? event

      @_event_handlers ||= Event.new_event_handlers
      handler = method || block
      @_event_handlers[event] << handler

      Subscription.new self, event, handler
    end

    # @overload unsubscribe(subscription)
    #   Unsubscribe from a #{Subscription}, as returned from {#subscribe}
    #   @param subscription [Subscription]
    #   @return [Boolean] true if the handler was able to be deleted.
    #
    # @overload unsubscribe(handler)
    #   Unsubscribe from first event this handler has been used to subscribe to..
    #   @param handler [Block, Method] Event handler used.
    #   @return [Boolean] true if the handler was able to be deleted.
    #
    # @overload unsubscribe(event, handler)
    #   Unsubscribe from specific handler on particular event.
    #   @param event [Symbol] Name of event originally subscribed to.
    #   @param handler [Block, Method] Event handler used.
    #   @return [Boolean] true if the handler was able to be deleted.
    #
    def unsubscribe(*args)
      @_event_handlers ||= Event.new_event_handlers

      case args.size
        when 1
          case args.first
            when Subscription
              # Delete specific event handler.
              subscription = args.first
              raise ArgumentError, "Incorrect publisher for #{Subscription}: #{subscription.publisher}" unless subscription.publisher == self
              unsubscribe subscription.event, subscription.handler
            when Proc, Method
              # Delete first events that use the handler.
              handler = args.first
              !!@_event_handlers.find {|_, handlers| handlers.delete handler }
            else
              raise TypeError, "handler must be a #{Subscription}, Block or Method: #{args.first}"
          end
        when 2
          event, handler = args
          raise TypeError, "event name must be a Symbol: #{event}" unless event.is_a? Symbol
          raise TypeError, "handler name must be a Proc/Method: #{handler}" unless handler.is_a? Proc or handler.is_a? Method
          !!@_event_handlers[event].delete(handler)
        else
          raise ArgumentError, "Requires 1..2 arguments, but received #{args.size} arguments"
      end
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
      raise ArgumentError, "#{self.class} does not handle #{event.inspect}" unless events.include? event

      # Do nothing if the object is disabled.
      return if respond_to?(:enabled?) and not enabled?

      if respond_to? event
        return :handled if send(event, self, *args) == :handled
      end

      if defined? @_event_handlers
        @_event_handlers[event].reverse_each do |handler|
          return :handled if handler.call(self, *args) == :handled
        end
      end

      nil
    end

    # The list of events that this object can publish/subscribe.
    def events
      self.class.events
    end

    # Add singleton methods to the class that includes Event.
    def self.included(base)
      class << base
        def events
          # Copy the events already set up for your parent.
          @events ||= if superclass.respond_to? :events
                        superclass.events.dup
                      else
                        []
                      end
        end

        def event(event)
          events.push event.to_sym unless events.include? event
          event
        end
      end
    end
  end
end