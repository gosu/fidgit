module Fidgit
  # Redirects methods to an object, but does not mask methods and ivars from the calling context.
  module RedirectorMethods
    # Evaluate a block accessing methods and ivars from the calling context, but calling methods (not ivars) on this
    # object if they don't exist on the calling context.
    def instance_methods_eval(&block)
      raise ArgumentEror unless block_given?

      context = eval('self', block.binding)

      context.send :push_redirection_target, self

      begin
        yield
      ensure
        context.send :pop_redirection_target
      end

      self
    end

    protected
    def push_redirection_target(target)
      meta_class = class << self; self; end
      base_methods = Object.public_instance_methods

      methods_to_hide = meta_class.public_instance_methods - base_methods
      methods_to_add = target.public_methods - base_methods

      methods_overridden = []
      methods_to_hide.each do |meth|
        # Take a reference to the method we are about to override.
        reference = method meth
        if reference.owner == meta_class
          methods_overridden.push [meth, reference]
          meta_class.send :remove_method, meth
        end
      end

      # Add a method, to redirect calls to the target.
      methods_to_add.each do |meth|
        meta_class.send :define_method, meth do |*args, &block|
          target.send meth, *args, &block
        end
      end

      redirection_stack.push [target, methods_overridden, methods_to_add]

      target
    end

    protected
    def pop_redirection_target
      meta_class = class << self; self; end

      target, methods_to_unoverride, methods_to_remove = redirection_stack.pop

      # Remove the redirection methods
      methods_to_remove.reverse_each do |meth|
        meta_class.send :remove_method, meth
      end

      # Replace with the previous versions of the methods.
      methods_to_unoverride.reverse_each do |meth, reference|
        meta_class.send :define_method, meth, reference
      end

      target
    end

    # Direct access to the redirection stack.
    private
    def redirection_stack
      @_redirection_stack ||= []
    end
  end
end

class Object
  include Fidgit::RedirectorMethods
end