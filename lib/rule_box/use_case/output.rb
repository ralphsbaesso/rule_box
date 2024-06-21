# frozen_string_literal: true

module RuleBox
  class UseCase
    class Output < RuleBox::Data
      def self.__private_data?
        false
      end
    end
  end
end
