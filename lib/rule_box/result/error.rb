# frozen_string_literal: true

module RuleBox
  class Result
    class Error < RuleBox::Result
      def status
        'error'
      end

      def concat!(result)
        _concat_meta!(result.meta)
        _concat_errors!(result.errors)
      end
    end
  end
end
