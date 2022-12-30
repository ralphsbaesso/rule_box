# frozen_string_literal: true

require_relative '../examples/load'

RSpec.describe RuleBox::Mapper do
  context '.all_strategies' do
    it 'Show all strategy by class' do
      strategies = CreateUser::UseCase.all_strategies
      expect(strategies).to be_an(Array)

      strategy = strategies.first
      expect(strategy).to be_a(Hash)
    end
  end

  context '.strategies' do
    it 'Show strategies by class' do
      strategies = CreateUser::UseCase.strategies
      expect(strategies.count).to eq(4)
    end
  end
end
