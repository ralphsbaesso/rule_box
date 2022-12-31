# frozen_string_literal: true

module RuleBox
  class Strategy
    class Stop < StandardError
      attr_reader :__result

      def initialize(__result: nil)
        super()
        @__result = __result
      end
    end

    def perform(_use_case, _result)
      raise "Must implement this method in the \"#{self.class.name}\" class!"
    end

    def stop?
      !@stop.nil?
    end

    private

    def stop(&block)
      block&.call
      @stop
    end

    def stop!(&block)
      @stop = true
      result = block&.call
      raise Stop.new(__result: result)
    end

    def turn
      self.class::Result.new
    end

    def _neutral_result
      turn.neutral.class.new
    end

    class Result; end

    class << self
      attr_reader :description

      def desc(description)
        @description = description
      end

      def map_result(method_name, result_class)
        self::Result.define_method(method_name) do |result = nil, **args|
          result_class.new(result, **args)
        end
      end
    end

    map_result :neutral, RuleBox::Result::Neutral
    map_result :success, RuleBox::Result::Success
    map_result :error, RuleBox::Result::Error
  end
end
