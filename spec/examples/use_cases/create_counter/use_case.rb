# frozen_string_literal: true

module CreateCounter
  class Create < Strategy
    def perform(use_case, _result)
      counter = Counter.new
      use_case.counter = counter
    end
  end

  class StrategyBase < Strategy
    def perform(use_case, _)
      counter = use_case.counter
      value = use_case.attr.value
      factor = use_case.attr.factor

      counter.increment(value * factor)
      stop! { turn.success(data: counter) } if counter.amount > 10
    end
  end

  class FirstStep < StrategyBase; end
  class SecondStep < StrategyBase; end
  class ThirdStep < StrategyBase; end

  class UseCase < UseCaseBase
    attributes :value, :factor
    attr_accessor :counter

    rules Create,
          FirstStep,
          SecondStep,
          ThirdStep
  end
end
