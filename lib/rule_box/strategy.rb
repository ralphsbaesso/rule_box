# frozen_string_literal: true

module RuleBox
  class Strategy
    include RuleBox::MethodHelper
    attr_reader :facade

    delegate_methods :add_error, :current_method, :bucket, :entity, :errors,
                     :executed, :last_result, :get, :set_status, :status, :steps, :use_case,
                     to: :facade, set_private: true

    def initialize(facade = nil)
      @facade = facade
    end

    def perform
      raise 'Must implement this method'
    end

    def instance_values
      hash = { strategy_name: self.class.name }
      instance_variables.each do |name|
        next if name == :@facade

        hash[name[1..]] = instance_variable_get(name)
      end

      hash
    end

    class << self
      attr_reader :description

      def desc(description)
        @description = description
      end

      def perform(&block)
        define_method :perform do |result = nil|
          instance_exec(result, &block)
        end
      end
    end
  end
end
