# frozen_string_literal: true

require_relative '../../examples/load'

RSpec.describe CreateUser::UseCase do
  it do
    name = 'john'
    email = 'john@rule.box.com'

    use_case = CreateUser::UseCase.new
    result = use_case.exec name: name, email: email

    expect(result).to be_a(RuleBox::Result)
    expect(result.status).to eq('ok')

    user = result.data
    expect(user).to be_an(User)
    expect(user.name).to eq(name)
    expect(user.email).to eq(email)
  end

  context 'with error' do
    it 'must return "Name can\'t be empty!"' do
      name = nil
      email = 'john@rule.box.com'

      use_case = CreateUser::UseCase.new
      result = use_case.exec name: name, email: email

      expect(result).to be_a(RuleBox::Result)
      expect(result.status).to eq('error')
      expect(result.errors).to eq(["Name can't be empty!"])
    end

    it 'must return "Invalid email!"' do
      name = 'jua'
      email = 'john@rule_box.com'

      use_case = CreateUser::UseCase.new
      result = use_case.exec name: name, email: email

      expect(result).to be_a(RuleBox::Result)
      expect(result.status).to eq('error')
      expect(result.errors).to eq(['Invalid email!'])
    end
  end

  context 'with exception' do
    it 'return generic message' do
      name = 'james'
      email = 'john@rule.box.com'

      use_case = CreateUser::UseCase.new
      result = use_case.exec(name: name, email: email) { |bucket| bucket[:throw_error] = true }

      expect(result).to be_a(RuleBox::Result)
      expect(result.status).to eq('error')
      expect(result.errors).to eq(['Oops, something went wrong!'])
    end
  end
end
