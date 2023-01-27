# frozen_string_literal: true

module RuleBox
  class Strategy
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

    class << self
      def desc(description)
        @description = description
      end

      def description
        @description ||= name.gsub(/([A-Z][a-z])/) { |target| " #{target.downcase}" }.strip
      end
    end
  end
end
