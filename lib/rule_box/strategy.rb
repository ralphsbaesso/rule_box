# frozen_string_literal: true

module RuleBox
  class Strategy
    def perform(_use_case, _result)
      raise 'Must implement this method!'
    end

    def stop!(&block)
      @stop = true
      block&.call
    end

    def stop?
      !@stop.nil?
    end

    def Error(result = nil, **args)
      RuleBox::Result::Error.new(result, **args)
    end

    def Neutral(result = nil, **args)
      RuleBox::Result::Neutral.new(result, **args)
    end

    def Success(result = nil, **args)
      RuleBox::Result::Success.new(result, **args)
    end

    def instance_values
      { strategy_name: self.class.name }
    end

    class << self
      attr_reader :description

      def desc(description)
        @description = description
      end
    end
  end
end
