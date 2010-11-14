# encoding: utf-8

require_relative 'gosu_ext'

module Fidgit
  # An object that manages Schema values. Usually loaded from a YAML file.
  #
  # @example
  #   schema = Schema.new(YAML.load(file.read('default_schema.yml')))
  #   default_color = schema.default(Element, :disabled, :color)
  #   schema.merge_schema!(YAML.load(file.read('override_schema.yml'))
  #   overridden_color = schema.default(Element, :disabled, :color)
  class Schema
    CONSTANT_PREFIX = '?'

    # @param [Hash<Symbol => Hash>] schema data containing
    def initialize(schema)
      @constants = {}
      @elements = {}

      merge_schema! schema
    end

    # Merge in a hash containing constant values.
    #
    # @param [Hash<Symbol => Hash>] constants_hash Containing :colors, :constants and :elements hashes.
    def merge_schema!(schema)
      merge_constants!(schema[:constants]) if schema[:constants]
      merge_elements!(schema[:elements]) if schema[:elements]

      self
    end

    # Merge in a hash containing constant values. Arrays will be resolved as colors in RGBA or RGB format.
    #
    # @param [Hash<Symbol => Object>] constants_hash
    def merge_constants!(constants_hash)
      constants_hash.each_pair do |name, value|
        @constants[name] = case value
        when Array
          case value.size
          when 3 then Gosu::Color.rgb(*value)
          when 4 then Gosu::Color.rgba(*value)
          else
            raise "Colors must be in 0..255, RGB or RGBA array format"
          end
        else
          value
        end
      end

      self
    end

    # Merge in a hash containing default values for each element.
    #
    # @param [Hash<Symbol => Hash>] elements_hash
    def merge_elements!(elements_hash)
      elements_hash.each_pair do |klass_names, data|
        klass = Fidgit
        klass_names.to_s.split('::').each do |klass_name|
          klass = klass.const_get klass_name
        end

        raise "elements must be names of classes derived from #{Element}" unless klass.ancestors.include? Fidgit::Element
        @elements[klass] ||= {}
        @elements[klass].deep_merge! data
      end

      self
    end

    # Get the constant value associated with +name+.
    #
    # @param [Symbol] name
    # @return [Object]
    def constant(name)
      @constants[name]
    end

    # @param [Class] klass Class to look for defaults for.
    # @param [Symbol, Array<Symbol>] names Hash names to search for in that class's schema.
    def default(klass, names)
      raise ArgumentError, "#{klass} is not a descendent of the #{Element} class" unless klass.ancestors.include? Element
      value = default_internal(klass, Array(names), true)
      raise("Failed to find named value #{names.inspect} for class #{klass}") unless value
      value
    end

    protected
    # @param [Class] klass Class to look for defaults for.
    # @param [Array<Symbol>] names Hash names to search for in that class's schema.
    # @param [Boolean] default_to_outer Whether to default to an outer value (used internally)
    def default_internal(klass, names, default_to_outer)
      # Find the value by moving through the nested hash via the names.
      value = @elements[klass]

      names.each do |name|
        break unless value.is_a? Hash
        value = value.has_key?(name) ? value[name] : nil
      end

      # Convert the value to a color/constant if they are symbols.
      value = if value.is_a? String and value[0] == CONSTANT_PREFIX
          str = value[1..-1]
          constant(str.to_sym) || value # If the value isn't a constant, return the string.
        else
          value
      end

      # If we didn't find the value for this class, default to parent class value.
      if value.nil? and klass != Element and klass.ancestors.include? Element
        # Check if any ancestors define the fully named value.
        value = default_internal(klass.superclass, names, false)
      end

      if value.nil? and default_to_outer and names.size > 1
        # Check the outer values (e.g. if [:hover, :color] is not defined, try [:color]).
        value = default_internal(klass, names[1..-1], true)
      end

      value
    end
  end
end
