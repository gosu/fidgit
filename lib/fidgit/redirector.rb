require 'mixico'

module Fidgit
  module Redirector
    # @param [Object] target Target of the redirection.
    # @param [Array<Symbol>] methods ([]) If empty, redirect all methods, otherwise only redirect named ones.
    # @return [Module]
    def self.create(target, *methods)
      my_module = Module.new

      if methods.empty?
        # Equivalent to gen_eval, but won't crash and probably lower performance.
        my_module.send :define_method, :method_missing do |method, *args, &block|
           target.send method, *args, &block
        end
      else
        # Just redirect named methods.
        methods.each do |method|
          my_module.send :define_method, method do |*args, &block|
            target.send method, *args, &block
          end
        end
      end

      my_module
    end
  end
end