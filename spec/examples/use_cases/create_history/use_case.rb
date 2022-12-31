# frozen_string_literal: true

module CreateHistory
  class StrategyBase < Strategy
    def perform; end
  end

  class FirstStep < StrategyBase; end

  class SecondStep < StrategyBase; end

  class ThirdStep < StrategyBase; end

  class FinalStep < Strategy
    def perform(use_case)
      history = create_history use_case.attr.name, use_case.event
      turn.success(data: history)
    end

    private

    def create_history(name, event)
      history = History.new
      history.name = name
      history.event = event
      history
    end
  end

  class UseCase < UseCaseAdmin
    attributes :name
    attr_accessor :history

    rules FirstStep,
          SecondStep,
          ThirdStep,
          FinalStep

    after_rules do |use_case|
      use_case.event['after_rules'] += 1
    end

    after_rule do |use_case|
      use_case.event['after_rule'] += 1
    end

    around_rules do |use_case, &block|
      use_case.event['around_rules'] += 1
      block.call
      use_case.event['around_rules'] += 1
    end

    around_rule do |use_case, &block|
      use_case.event['around_rule'] += 1
      block.call
      use_case.event['around_rule'] += 1
    end

    before_rules do |use_case|
      use_case.event['before_rules'] += 1
    end

    before_rule do |use_case|
      use_case.event['before_rule'] += 1
    end

    def event
      @event ||= {
        'after_rule' => 0,
        'after_rules' => 0,
        'around_rule' => 0,
        'around_rules' => 0,
        'before_rule' => 0,
        'before_rules' => 0
      }
    end
  end
end
