# frozen_string_literal: true

module RuleBox
  module Mapper
    def rules(*rules)
      @current_rules = rules
    end

    def strategies
      current_rules.clone
    end

    private

    def current_rules
      @current_rules ||= []
    end
  end
end
