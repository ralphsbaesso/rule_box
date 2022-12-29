# frozen_string_literal: true

module RuleBox
  class Result
    class Neutral < RuleBox::Result
      def status
        'neutral'
      end

      def concat!(result)
        _concat_meta!(result.meta)
        _concat_data!(result.data)
        _concat_errors!(result.errors)
      end
    end
  end
end
