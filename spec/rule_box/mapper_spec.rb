# frozen_string_literal: true

RSpec.describe RuleBox do
  context '.show_strategies' do
    it 'Show all strategy by class' do
      strategies = User.show_strategies
      expect(strategies.count).to eq(2)
      strategy_insert = strategies.find { |strategy| strategy[:method] == :insert }
      expect(strategy_insert[:strategies].count).to eq(4)
    end
  end
end
