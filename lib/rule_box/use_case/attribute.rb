# frozen_string_literal: true

module RuleBox
  class UseCase
    class Attribute
      def initialize(**args)
        args.each do |key, value|
          key = "#{key}="
          send(key, value) if respond_to? key
        end
      end

      def names
        self.class.names
      end

      class << self
        def names
          attribute_names.clone
        end

        private

        def attribute_names
          @attribute_names ||= []
        end
      end
    end
  end
end
