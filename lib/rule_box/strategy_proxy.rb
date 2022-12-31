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
    last_result ||= _neutral_result
    result = perform!(use_case, last_result)

    if valid_result?(result)
      result
    else
      last_result
    end
  end

  private

  def perform!(use_case, last_result)
    parameters_size = @strategy.method(:perform).parameters.size

    case parameters_size
    when 2 then @strategy.perform(use_case, last_result)
    when 1 then @strategy.perform(use_case)
    else @strategy.perform
    end
  rescue Strategy::Stop => e
    result = e.__result
    result if valid_result? result
  end

  def valid_result?(result)
    result.is_a? RuleBox::Result
  end

  class << self
    private

    def inherited(_sub)
      raise 'This class should not be extended!'
    end
  end
end
