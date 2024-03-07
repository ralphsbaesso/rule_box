# frozen_string_literal: true

module RuleBox
  class Data
    include Enumerable
    def initialize(**args)
      init_data!(args)
      init_default_data!
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

    private

    def init_data!(args)
      args.each do |key, value|
        key = "#{key}="
        send(key, value) if respond_to? key
      end
    end

    def init_default_data!
      schema.each do |key, options|
        next unless send(key).nil?
        next if options['default'].nil?

        send("#{key}=", options['default'].clone)
      end
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
      def data_accessor(name, default: nil, callback: nil, **options)
        __data[name.to_s] = options.transform_keys(&:to_s).merge('default' => default).compact
        define_method(name) { read_attribute name }
        define_method("#{name}=") { |value| write_attribute(name, callback ? callback.call(value) : value) }
      end

      def alias_attribute(new_name, old_name)
        define_method(new_name) { read_attribute old_name }
        define_method("#{new_name}=") { |value| write_attribute(old_name, value) }
      end

      def schema
        __data.clone
      end

      private

      def __data
        @__data ||= {}
      end
    end
  end
end
