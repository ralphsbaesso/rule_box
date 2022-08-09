# frozen_string_literal: true

require_relative '../../../lib/rule_box'

module Calc
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

  class Plus < RuleBox::Strategy
    perform do |results|
      results.reduce(&:+)
    end
  end

  class UseCase
    include RuleBox::Mapper

    rules FirstValue,
          SecondValue,
          Plus
  end
end
