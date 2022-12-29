# frozen_string_literal: true

module RuleBox
  class UseCase
    class Dependency
      def initialize(**args)
        check_dependencies!(args)

        args.each do |key, value|
          instance_variable_set("@#{key}", value) if respond_to? key
        end
      end

      def names
        self.class.dependencies.keys
      end

      private

      def check_dependencies!(arg_dependencies)
        errors = []

        self.class.dependencies.each do |key, block|
          result = check_dependency!(key, block, arg_dependencies)
          errors << result if result
        end

        raise errors.join("\n") unless errors.empty?
      end

      def check_dependency!(key, block, args)
        return "missing keyword: #{key}" unless args.key? key

        block&.call(args[key])
      rescue StandardError => e
        e.message
      end

      def self.dependencies
        @dependencies ||= {}
      end
    end
  end
end
