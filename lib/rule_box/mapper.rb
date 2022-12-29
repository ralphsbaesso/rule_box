# frozen_string_literal: true

module RuleBox
  module Mapper
    def rules(*rules, **options)
      current_rules['strategies'] = rules
      options.each do |k, v|
        word = k.to_s.downcase
        raise "Reserved word [#{word}]" if word == 'strategies'

        current_rules[k] = v
      end
    end

    def strategies
      current_rules['strategies']
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

    def current_rules
      @current_rules ||= {}
    end
  end
end
