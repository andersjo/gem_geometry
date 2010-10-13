module GemGeometry
  class ContextNode
    attr_reader :children, :type, :name, :values
    def initialize(name, type = :default)
      @type = type
      @name = name
      @children = []
      @current  = self
      @values = []
    end

    def current
      current? ? self : @current.current
    end

    def current?
      @current == self
    end

    def method_missing(meth,*args,&block)
      method_on_current = "_#{meth}"
      if current.respond_to?(method_on_current)
        current.send(method_on_current, *args, &block)
      else
        super
      end
    end

    def _introduce(name, type = :default, &block)
      @current = ContextNode.new(name, type)
      @children << @current
      yield
      @current = self
    end

    def all_values
      children.map(&:all_values).reduce(values, :+)
    end

    def as_hash
      {
        :type => type,
        :name => name,
        :children => children.map(&:as_hash),
        :values => values
      }
    end
  end
  
  class ValueNode < Struct.new(:value, :type)
    def to_s
      "#{value}/#{type}"
    end
  end

end
