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
      value = use_case.input.value
      factor = use_case.input.factor

      counter.increment(value * factor)
      stop! { use_case.new_output!(status: 'ok', data: counter) } if counter.amount > 10
    end
  end

  class FirstStep < StrategyBase; end
  class SecondStep < StrategyBase; end
  class ThirdStep < StrategyBase; end

  class UseCase < UseCaseBase
    inputs :value, :factor
    outputs :data, :errors, :meta, :status
    attr_accessor :counter

    rules Create,
          FirstStep,
          SecondStep,
          ThirdStep
  end
end
