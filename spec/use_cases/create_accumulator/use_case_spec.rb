# frozen_string_literal: true

require_relative '../../examples/load'

RSpec.describe CreateAccumulator::UseCase do
  it 'sum' do
    use_case = CreateAccumulator::UseCase.new
    result = use_case.exec initial_value: 1,
                           sum: 2

    expect(result).to be_a(Numeric)
    expect(result).to eq(3)
  end

  it 'sum and subtraction' do
    use_case = CreateAccumulator::UseCase.new
    result = use_case.exec initial_value: 10,
                           sum: 10,
                           subtraction: 5

    expect(result).to be_a(Numeric)
    expect(result).to eq(15)
  end

  it 'sum, subtraction, multiplication and division' do
    use_case = CreateAccumulator::UseCase.new
    result = use_case.exec initial_value: 100,
                           sum: 10,
                           subtraction: 20,
                           multiplication: 2,
                           division: 9

    expect(result).to be_a(Numeric)
    expect(result).to eq(20)
  end
end
