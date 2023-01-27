# frozen_string_literal: true

module RuleBox
  class Result
    class Success < RuleBox::Result
      def status
        'ok'
      end
    end
  end
end
