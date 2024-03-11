# frozen_string_literal: true

module RuleBox
  class Strategy
    extend RuleBox::Describe

    class ForcedStop < StandardError
      attr_reader :__result

      def initialize(result: nil)
        super()
        @__result = result
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
      raise ForcedStop.new(result: result)
    end
  end
end
