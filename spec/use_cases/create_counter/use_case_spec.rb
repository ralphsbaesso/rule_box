# frozen_string_literal: true

require_relative '../../examples/load'

RSpec.describe CreateCounter::UseCase do
  it 'must stop with 2 step' do
    value = 2
    factor = 3

    use_case = CreateCounter::UseCase.new
    output = use_case.exec value: value, factor: factor

    expect(output).to be_a(Hash)
    expect(output[:status]).to eq('ok')

    counter = output[:data]
    expect(counter).to be_an(Counter)

    expect(counter.step).to eq(2)
    expect(counter.amount).to eq(12)
  end

  it 'must stop with 1 step' do
    value = 5
    factor = 3

    use_case = CreateCounter::UseCase.new
    output = use_case.exec value: value, factor: factor

    expect(output).to be_a(Hash)
    expect(output[:status]).to eq('ok')

    counter = output[:data]
    expect(counter).to be_an(Counter)

    expect(counter.step).to eq(1)
    expect(counter.amount).to eq(15)
  end
end
