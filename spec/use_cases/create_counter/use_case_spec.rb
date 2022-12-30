# frozen_string_literal: true

require_relative '../../examples/load'

RSpec.describe CreateCounter::UseCase do
  it 'must stop with 2 step' do
    value = 2
    factor = 3

    use_case = CreateCounter::UseCase.new
    result = use_case.exec value: value, factor: factor

    expect(result).to be_a(RuleBox::Result)
    expect(result.status).to eq('ok')

    counter = result.data
    expect(counter).to be_an(Counter)

    expect(counter.step).to eq(2)
    expect(counter.amount).to eq(12)
  end

  it 'must stop with 1 step' do
    value = 5
    factor = 3

    use_case = CreateCounter::UseCase.new
    result = use_case.exec value: value, factor: factor

    expect(result).to be_a(RuleBox::Result)
    expect(result.status).to eq('ok')

    counter = result.data
    expect(counter).to be_an(Counter)

    expect(counter.step).to eq(1)
    expect(counter.amount).to eq(15)
  end
end
