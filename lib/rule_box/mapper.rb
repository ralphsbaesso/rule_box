# frozen_string_literal: true

module RuleBox
  module Mapper
    def self.included(klass)
      klass.extend(ClassMethods)
      mapped << klass
    end

    def self.mapped
      @mapped ||= Set.new
    end

    module ClassMethods
      def rules(*rules)
        add_rules :perform, rules
      end

      def rules_of(method, *rules)
        add_rules method.to_sym, rules
      end

      def strategies(method)
        current_rules[method]
      end

      def customize_result(&block)
        hooks[:customize_result] = block
      end

      def hooks
        @hooks ||= {}
      end

      def show_strategies
        current_rules.map do |method, strategies|
          {
            method: method,
            strategies: strategies.map do |strategy|
              {
                name: strategy.name,
                description: strategy.description
              }
            end
          }
        end
      end

      private

      def add_rules(method, rules)
        current_rules[method] = rules
      end

      def current_rules
        @current_rules ||= {}
      end
    end
  end
end
