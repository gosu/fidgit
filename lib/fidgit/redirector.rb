module Fidgit
  # Redirects methods to an object, but does not mask methods and ivars from the calling context.
  module RedirectorMethods
    # Evaluate a block accessing methods and ivars from the calling context, but calling public methods
    # (not ivars or non-public methods) on this object in preference.
    def instance_methods_eval(&block)
      raise ArgumentEror unless block_given?

      context = eval('self', block.binding)

      context.send :push_redirection_target, self

      begin
        yield context
      ensure
        context.send :pop_redirection_target
      end

      self
    end

    protected
    def push_redirection_target(target)
      meta_class = class << self; self; end
      base_methods = Object.public_instance_methods

      # Redirect just the public methods of the target, less those that are on Object.
      methods_to_redirect = target.public_methods - base_methods

      # Only hide those public/private/protected methods that are being redirected.
      methods_overridden = []
      [:public, :protected, :private].each do |access|
        methods_to_hide = meta_class.send("#{access}_instance_methods", false) & methods_to_redirect
        methods_to_hide.each do |meth|
          # Take a reference to the method we are about to override.
          methods_overridden.push [meth, method(meth), access]
          meta_class.send :remove_method, meth
        end
      end

      # Add a method, to redirect calls to the target.
      methods_to_redirect.each do |meth|
        meta_class.send :define_method, meth do |*args, &block|
          target.send meth, *args, &block
        end
      end

      redirection_stack.push [target, methods_overridden, methods_to_redirect]

      target
    end

    protected
    def pop_redirection_target
      meta_class = class << self; self; end

      target, methods_to_recreate, methods_to_remove = redirection_stack.pop

      # Remove the redirection methods
      methods_to_remove.reverse_each do |meth|
        meta_class.send :remove_method, meth
      end

      # Replace with the previous versions of the methods.
      methods_to_recreate.reverse_each do |meth, reference, access|
        meta_class.send :define_method, meth, reference
        meta_class.send access, meth unless access == :public
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