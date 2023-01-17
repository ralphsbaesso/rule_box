# frozen_string_literal: true

module CreateAccumulator
  class Init < Strategy
    def perform(use_case)
      use_case.attr.initial_value
    end
  end

  class Sum < Strategy
    def perform(use_case, result)
      sum = use_case.attr.sum

      if sum.is_a? Numeric
        result + sum
      else
        result
      end
    end
  end

  class Subtraction < Strategy
    def perform(use_case, result)
      subtraction = use_case.attr.subtraction

      if subtraction.is_a? Numeric
        result - subtraction
      else
        result
      end
    end
  end

  class Multiplication < Strategy
    def perform(use_case, result)
      multiplication = use_case.attr.multiplication

      if multiplication.is_a? Numeric
        result * multiplication
      else
        result
      end
    end
  end

  class Division < Strategy
    def perform(use_case, result)
      division = use_case.attr.division

      if division.is_a? Numeric
        result / division
      else
        result
      end
    end
  end

  class UseCase < UseCaseBase
    attributes :initial_value, :sum, :subtraction, :multiplication, :division
    attr_accessor :accumulator

    rules Init, Sum, Subtraction, Multiplication, Division
  end
end
