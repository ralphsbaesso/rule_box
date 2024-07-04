# frozen_string_literal: true

require_relative '../../examples/load'

RSpec.describe CreateUser::UseCase do
  it do
    name = 'john'
    email = 'john@rule.box.com'

    use_case = CreateUser::UseCase.new
    output = use_case.exec name: name, email: email

    expect(output).to be_a(Hash)
    expect(output[:status]).to eq('success')

    user = output[:data]
    expect(user).to be_an(User)
    expect(user.name).to eq(name)
    expect(user.email).to eq(email)
  end

  context 'with error' do
    it 'must return "Name can\'t be empty!"' do
      name = nil
      email = 'john@rule.box.com'

      use_case = CreateUser::UseCase.new
      output = use_case.exec name: name, email: email

      expect(output).to be_a(Hash)
      expect(output[:status]).to eq('error')
      expect(output[:errors]).to eq(["Name can't be empty!"])
    end

    it 'must return "Invalid email!"' do
      name = 'jua'
      email = 'john@rule_box.com'

      use_case = CreateUser::UseCase.new
      output = use_case.exec name: name, email: email

      expect(output).to be_a(Hash)
      expect(output[:status]).to eq('error')
      expect(output[:errors]).to eq(['Invalid email!'])
    end

    it 'must return two error messages' do
      name = nil
      email = 'john@rule_box.com'

      use_case = CreateUser::UseCase.new
      output = use_case.exec name: name, email: email

      expect(output).to be_a(Hash)
      expect(output[:status]).to eq('error')
      expect(output[:errors].size).to eq(2)
    end
  end

  context 'with exception' do
    it 'return generic message' do
      name = 'james'
      email = 'john@rule.box.com'

      use_case = CreateUser::UseCase.new
      use_case.throw_error = true
      output = use_case.exec name: name, email: email

      expect(output).to be_a(Hash)
      expect(output[:status]).to eq('error')
      expect(output[:errors]).to eq(['Oops, something went wrong!'])
    end
  end
end
