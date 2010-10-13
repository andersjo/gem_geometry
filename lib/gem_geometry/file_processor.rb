module GemGeometry
  class FileProcessor
    attr_reader :context
    def initialize
      @context = ContextNode.new('filename', :file)
    end

    def process(sexp)
      process_method = "process_#{sexp.sexp_type}"
      if respond_to? process_method
        send(process_method, sexp)
      else
        sexps, syms = sexp.values.partition {|v| v.is_a?(Sexp) }
        sexps.each {|s| process(s) }
        syms.each  {|sym| add_value(sym, sexp.sexp_type) }
      end
    end

    def process_context(sexp)
      introduce_context(sexp[1], sexp[0], sexp)
    end
    alias process_defn process_context
    alias process_class process_context
    alias process_module process_context

    def introduce_context(name, type, sexp)
      @context.introduce(name, type) do
        sexp.values.each {|v| process(v) if v.is_a?(Sexp) }
      end
    end

    def add_value(value, type)
      @context.current.values << ValueNode.new(value, type)
    end

  end

end

