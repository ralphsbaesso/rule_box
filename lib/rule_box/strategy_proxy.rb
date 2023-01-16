# frozen_string_literal: true

class StrategyProxy < RuleBox::Strategy
  attr_reader :exception

  def initialize(strategy)
    @strategy = strategy
  end

  def stop?
    @strategy.stop?
  end

  def perform(use_case, last_result)
    perform!(use_case, last_result)
  end

  private

  def perform!(use_case, last_result)
    parameters_size = @strategy.method(:perform).parameters.size

    case parameters_size
    when 2 then @strategy.perform(use_case, last_result)
    when 1 then @strategy.perform(use_case)
    else @strategy.perform
    end
  rescue Strategy::ForcedStop => e
    e.__result
  end

  class << self
    private

    def inherited(_sub)
      raise 'This class should not be extended!'
    end
  end
end
