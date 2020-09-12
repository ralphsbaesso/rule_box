# frozen_string_literal: true

module RuleBox::Mapper
  def self.included(klass)
    klass.extend(ClassMethods)
    mapped << klass
  end

  def self.mapped
    @mapped ||= Set.new
  end

  module ClassMethods
    def rules_of_insert(*rules)
      add_rules :insert, rules
    end

    def rules_of_update(*rules)
      add_rules :update, rules
    end

    def rules_of_delete(*rules)
      add_rules :delete, rules
    end

    def rules_of_select(*rules)
      add_rules :select, rules
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
