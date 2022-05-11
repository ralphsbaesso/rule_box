# frozen_string_literal: true

module RuleBox
  module Mapper
    extend RuleBox::ExecutionHook

    if const_defined? 'ActiveSupport::Concern'
      # to Rails project
      extend ActiveSupport::Concern
      included { include RuleBox::ExecutionHook }
    else
      def self.included(klass)
        klass.include RuleBox::ExecutionHook
        klass.extend ClassMethods
        mapped << klass
      end
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
