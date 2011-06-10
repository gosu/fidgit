module Gosu
  class << self
    alias_method :register_entity_fidgit, :register_entity

    protected
    def init_entities
      @entities = {}
    end

    public
    def register_entity(name, image)
      raise ArgumentError.new("Entity already registered") if @entities.has_key? name

      name = name.to_sym
      register_entity_fidgit(name, image)
      @entities[name] = image
      nil
    end

    public
    def entity(name)
      @entities[name.to_sym]
    end
  end

  init_entities
end