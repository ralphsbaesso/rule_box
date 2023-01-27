# frozen_string_literal: true

module RuleBox
  class StrategyProxy < RuleBox::Strategy
    attr_reader :exception

    def initialize(strategy)
      super()

      @strategy = strategy
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

      def inherited(sub)
        super

        raise 'This class should not be extended!'
      end
    end
  end
end
