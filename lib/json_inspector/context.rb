require 'pp'

module JsonInspector
  class Context < BasicObject
    attr_reader :filename, :options, :doc, :stack

    OMITTED_VALUE = '< omitted >'.freeze

    def initialize(filename, options = {})
      @options  = options
      @filename = filename
      @basename = ::File.basename(filename)

      @doc   = ::MultiJson.load(::File.read(filename))
      @stack = Stack.new(doc)
    end

    def _prompt_
      [
        ->(obj, nest_level, _) { "inspect(#{@basename}:#{@stack.path})>" },
        ->(obj, nest_level, _) { "inspect(#{@basename}:#{@stack.path})*" }
      ]
    end

    def find_key(query)
      enumerator('', ::Float::INFINITY).select { |key, _| key.split(?.).include?(query) }.map { |key, _| key }
    end

    alias :fk :find_key

    def find(query)
      enumerator('', ::Float::INFINITY).select { |key, value| value == query }.map { |key, _| key }
    end

    alias :f :find

    def tree(*args)
      raise ::ArgumentError.new("wrong number of arguments (given #{args.size}, expected 2)") if args.size > 2

      initial_key = args.first.is_a?(::String) ? args.shift : ''
      level       = args.last.nil? ? ::Float::INFINITY : args.last.to_i

      enumerator(initial_key, level).map { |key, value| key unless value.is_a?(::Enumerable) }.compact
    end

    alias :t :tree

    def keys(selector = '')
      value = @stack.current(selector)
      get_keys(value)
    end

    alias :k :keys

    def into(selector)
      @stack.push(selector)
      current
    end

    alias :i :into

    def show(selector)
      @stack.current(selector)
    end

    alias :s :show

    def out
      @stack.pop
      current
    end

    alias :o :out

    def reset
      @stack.clear!
      nil
    end

    alias :r :reset

    def current
      @stack.current
    end

    alias :c :current

    private

    def enumerator(initial_key, level)
      ::Enumerator.new do |yielder|
        recursive(initial_key, level, 0, yielder, @stack.current(initial_key))
      end
    end

    def recursive(initial_key, level, current_level, yielder, value)
      return unless value.is_a?(::Enumerable)

      get_keys(value).each do |key|
        new_value         = value[key]
        new_initial_key   = [initial_key, key.to_s].reject(&:empty?).join('.')
        new_current_level = current_level + 1

        if new_current_level < level
          yielder.yield(new_initial_key, new_value)
          recursive(new_initial_key, level, new_current_level, yielder, new_value)
        else
          yielder.yield(*get_omitted_key_and_value(new_initial_key, new_value))
        end
      end
    end

    def get_keys(value)
      case
      when value.is_a?(::Array)
        (0...value.size).to_a
      when value.respond_to?(:keys)
        value.keys
      else
        []
      end
    end

    def get_omitted_key_and_value(initial_key, value)
      return ["#{initial_key}...", OMITTED_VALUE] if value.is_a?(::Enumerable)
      [initial_key, value]
    end
  end
end
