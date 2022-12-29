# frozen_string_literal: true

module RuleBox
  class Result
    class Success < RuleBox::Result
      def status
        'ok'
      end

      def concat!(result)
        _concat_meta!(result.meta)
        _concat_data!(result.data)
      end
    end
  end
end
