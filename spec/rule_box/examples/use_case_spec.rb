# frozen_string_literal: true

require_relative '../../examples/with_use_case'

RSpec.describe 'UseCase' do
  it do
    use_case = UseCase.new
    facade = RuleBox::Facade.new
    result = facade.exec use_case

    expect(result).to eq(3)
  end
end
