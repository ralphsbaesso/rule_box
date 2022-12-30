# frozen_string_literal: true

module RuleBox
  module Mapper
    def rules(*rules, **options)
      current_rules['default'] = rules
      options.each do |k, v|
        word = k.to_s.downcase
        raise "Reserved word [#{word}]" if word == 'default'

        current_rules[k] = v.is_a?(Array) ? v : [v]
      end
    end

    def strategies(type = 'default')
      current_rules[type]
    end

    def all_strategies
      current_rules.map do |type, strategies|
        {
          type: type,
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

    def current_rules
      @current_rules ||= {}
    end
  end
end
