module JsonInspector
  class Stack
    attr_reader :doc

    def initialize(doc)
      @doc  = doc
      @keys = []
      @doc.extend(Hashie::Extensions::DeepFind)
      @doc.extend(Hashie::Extensions::DeepFetch)
    end

    def push(keys)
      keys = keys.split(?.)
      @keys += keys
    end

    def pop
      @keys.pop
    end

    def path
      @keys.join(?.)
    end

    def clear!
      @keys = []
    end

    def current(keys = '')
      keys = @keys + keys.split(?.)
      @doc.deep_fetch(*keys) { nil }
    end
  end
end
