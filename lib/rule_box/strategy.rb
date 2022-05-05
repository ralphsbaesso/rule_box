# frozen_string_literal: true

module RuleBox
  class Strategy
    DELEGATES = %i[add_error current_method bucket errors executed get model set_status status steps].freeze
    DELEGATES.each do |method|
      define_method method do |*rest, **restkey|
        @facade.send method, *rest, **restkey
      end
    end

    def initialize(facade: nil, last_result: nil)
      @facade = facade
      @last_result = last_result
    end

    def process
      raise 'Must implement this method'
    end

    private

    attr_reader :last_result

    class << self
      attr_reader :description

      def desc(description)
        @description = description
      end
    end
  end
end
