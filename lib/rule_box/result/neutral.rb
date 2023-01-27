# frozen_string_literal: true

module RuleBox
  class Result
    class Neutral < RuleBox::Result
      def status
        'neutral'
      end
    end
  end
end
