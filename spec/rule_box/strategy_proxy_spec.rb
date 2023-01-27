# frozen_string_literal: true

RSpec.describe RuleBox::StrategyProxy do
  context '.inherited' do
    it 'don\'t can inherited' do
      expect do
        class NewStrategy < RuleBox::StrategyProxy; end
      end.to raise_error 'This class should not be extended!'
    end
  end
end
