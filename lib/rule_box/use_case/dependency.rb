# frozen_string_literal: true

module RuleBox
  class UseCase
    class Dependency
      def initialize(**args)
        init_data! args.transform_keys(&:to_s)
      end

      def schema
        self.class.schema
      end

      private

      def init_data!(args)
        errors = []

        schema.each do |key_name, options|
          value = args[key_name].nil? ? options['default'] : args[key_name]
          args_key = args.key?(key_name) ? key_name : nil
          error = check_dependency(key_name, args_key, value)
          if error
            errors << error
          else
            instance_variable_set("@#{key_name}", value)
          end
        end

        raise errors.join("\n") unless errors.empty?
      end

      def check_dependency(key, args_key, value)
        options = schema[key]
        return if options['optional'] && value.nil?

        if !value.nil?
          validate = self.class.send(:validations)[key]
          validate&.call(value, options)
        elsif args_key.nil?
          "missing keyword: #{key}"
        end
      rescue StandardError => e
        e.message
      end

      class << self
        def add_dependency(name, default: nil, optional: false, **options, &validate)
          name = name.to_s
          dependencies[name] =
            if !default.nil?
              options.transform_keys(&:to_s).merge('default' => default, 'optional' => true)
            else
              options.transform_keys(&:to_s).merge('optional' => ![nil, false].include?(optional))
            end
          validations[name] = validate if validate
          attr_accessor name
        end

        def schema
          dependencies.clone
        end

        private

        def dependencies
          @dependencies ||= {}
        end

        def validations
          @validations ||= {}
        end
      end
    end
  end
end
