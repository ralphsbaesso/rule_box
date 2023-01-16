# frozen_string_literal: true

module RuleBox
  class Strategy
    class ForcedStop < StandardError
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
      @stop = true
      block&.call
    end

    def stop!(&block)
      @stop = true
      result = block&.call
      raise ForcedStop.new(__result: result)
    end

    class << self
      attr_reader :description

      def desc(description)
        @description = description
      end
    end
  end
end
