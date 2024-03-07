# frozen_string_literal: true

module CreateAccumulator
  class Init < Strategy
    def perform(use_case)
      use_case.input.initial_value
    end
  end

  class Sum < Strategy
    def perform(use_case, result)
      sum = use_case.input.sum

      if sum.is_a? Numeric
        result + sum
      else
        result
      end
    end
  end

  class Subtraction < Strategy
    def perform(use_case, result)
      subtraction = use_case.input.subtraction

      if subtraction.is_a? Numeric
        result - subtraction
      else
        result
      end
    end
  end

  class Multiplication < Strategy
    def perform(use_case, result)
      multiplication = use_case.input.multiplication

      if multiplication.is_a? Numeric
        result * multiplication
      else
        result
      end
    end
  end

  class Division < Strategy
    def perform(use_case, result)
      division = use_case.input.division

      if division.is_a? Numeric
        result / division
      else
        result
      end
    end
  end

  class CreateResult < Strategy
    def perform(use_case, result)
      use_case.output.result = result
    end
  end

  class UseCase < UseCaseBase
    inputs :initial_value, :sum, :subtraction, :multiplication, :division
    outputs :result
    attr_accessor :accumulator

    rules Init, Sum, Subtraction, Multiplication, Division, CreateResult
  end
end
