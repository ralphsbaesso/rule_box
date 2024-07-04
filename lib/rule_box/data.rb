# frozen_string_literal: true

module RuleBox
  class Data
    include Enumerable
    def initialize(**args)
      init_data!(args.transform_keys(&:to_s))
    end

    def each(&block)
      instance_values.each(&block)
    end

    def schema
      self.class.schema
    end

    def instance_values
      __attributes.clone
    end

    def inspect
      return "#<#{self.class}>" if __attributes.empty?

      inspection = __attributes.map { |key, value| "#{key}: #{value.inspect}" }.join(', ')
      "#<#{self.class} #{inspection}>"
    end

    def to_h
      __attributes.keys.map { |key| [key.to_sym, send(key)] }.to_h
    end

    private

    def init_data!(args)
      schema.each do |key, options|
        if args.key?(key)
          send("#{key}=", args[key])
        elsif options.key? 'default'
          send("#{key}=", options['default'].clone)
        end
      end

      validate! if self.class.send(:__validate?)
    end

    def validate!
      raise NotImplementedError
    end

    def read_attribute(key)
      __attributes[key.to_s]
    end

    def write_attribute(key, value)
      __attributes[key.to_s] = value
    end

    def __attributes
      @__attributes ||= {}
    end

    class << self
      def data_accessor(name, **options)
        options = options.transform_keys(&:to_s)
        callback = options.delete('callback') if options['callback'].is_a?(Proc)
        validate = options.delete('validate') if options['validate'].respond_to?(:call)

        __data[name.to_s] = options
        __validations[name.to_s] = validate if __validate?

        setter = "#{name}="
        define_method(name) { read_attribute name }
        define_method(setter) { |value| write_attribute(name, callback ? callback.call(value) : value) }
        instance_eval { private setter } if __private_data?
      end

      def add(name, **options)
        data_accessor(name, **options)
      end

      def schema
        __data.clone
      end

      private

      def __private_data?
        true
      end

      def __validate?
        false
      end

      def __data
        @__data ||= {}
      end

      def __validations
        @__validations ||= {}
      end
    end
  end
end
