# frozen_string_literal: true

module RuleBox
  class Dependency < Data
    def self.__validate?
      true
    end

    private

    def validate!
      validations = self.class.send(:__validations)
      errors = schema.filter_map do |key_name, options|
        if !__attributes.key?(key_name)
          InvalidDependency.new("missing keyword: #{key_name}")
        elsif validations[key_name]
          value = __attributes[key_name]
          validation = validations[key_name]
          if validation.arity == 1
            validation.call(value)
          else
            validation.call(value, options)
          end
        end
      end

      messages = errors.filter { |e| e.is_a?(InvalidDependency) }.map(&:message)
      raise InvalidDependency, messages.join("\n") unless messages.empty?
    end
  end
end
