# frozen_string_literal: true

require_relative '../../examples/load'

RSpec.describe CreateHistory::UseCase do
  it 'must create history' do
    admin = Admin.new
    name = 'history_name'

    use_case = CreateHistory::UseCase.new admin: admin
    result = use_case.exec name: name

    expect(result).to be_a(RuleBox::Result)
    expect(result.status).to eq('ok')

    history = result.data
    expect(history).to be_an(History)
    expect(history.name).to eq(name)

    expect(history.event['after_rule']).to eq(4)
    expect(history.event['after_rules']).to eq(1)
    expect(history.event['around_rule']).to eq(8)
    expect(history.event['around_rules']).to eq(2)
    expect(history.event['before_rule']).to eq(4)
    expect(history.event['before_rules']).to eq(1)
  end

  context 'with exception' do
    before do
      RuleBox.rescue_from Exception do |use_case|
        RuleBox::Result::Error.new(errors: ['Oops!'], data: use_case)
      end
    end

    after { RuleBox.clear_hooks! }

    it 'handle unexpected exception' do
      allow_any_instance_of(CreateHistory::FinalStep)
        .to receive(:create_history).and_raise('any failure')

      admin = Admin.new
      name = 'history_name'

      use_case = CreateHistory::UseCase.new admin: admin
      result = use_case.exec name: name

      expect(result).to be_a(RuleBox::Result)
      expect(result.status).to eq('error')
      expect(result.errors).to eq(['Oops!'])
    end
  end
end
