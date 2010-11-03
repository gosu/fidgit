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
      base_methods = Object.new.public_methods

      methods_to_hide = meta_class.public_instance_methods - base_methods
      methods_to_add = target.public_methods - base_methods

      methods_overridden = []
      methods_to_hide.each do |method|
        # Make a copy of the original method.
        meta_class.send :alias_method, "redirected_#{method}", method

        # Try to remove the method, but if that fails, it means the method is defined elsewhere,
        # so we don't need the copy we just made.
        begin
          meta_class.send :remove_method, method
          methods_overridden.push method
        rescue Exception => ex
          meta_class.send :remove_method, "redirected_#{method}"
        end
      end

      # Add a method, to redirect calls to the target.
      methods_to_add.each do |method|
        meta_class.send :define_method, method do |*args, &block|
          target.send method, *args, &block
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
      methods_to_remove.reverse_each do |method|
        meta_class.send :remove_method, method
      end

      # Replace with the previous versions of the methods.
      methods_to_unoverride.reverse_each do |method|
        meta_class.send :alias_method, method, "redirected_#{method}"
        meta_class.send :remove_method, "redirected_#{method}"
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