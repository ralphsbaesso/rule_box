# frozen_string_literal: true

require_relative '../../lib/rule_box'

module Strategy
  class FirstValue < RuleBox::Strategy
    perform do
      1
    end
  end

  class SecondValue < RuleBox::Strategy
    perform do |result|
      [result, 2]
    end
  end

  class Calc < RuleBox::Strategy
    perform do |results|
      results.reduce(&:+)
    end
  end
end

class UseCase
  include RuleBox::Mapper

  rules Strategy::FirstValue,
        Strategy::SecondValue,
        Strategy::Calc
end
