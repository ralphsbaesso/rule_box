# frozen_string_literal: true

module RuleBox
  class Result
    class Error < RuleBox::Result
      def status
        'error'
      end
    end
  end
end
