# frozen_string_literal: true

require_relative '../examples/load'

RSpec.describe RuleBox::Mapper do
  context '.strategies' do
    it 'Show strategies by class' do
      strategies = CreateUser::UseCase.strategies
      expect(strategies.count).to eq(4)
    end
  end
end
