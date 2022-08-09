# frozen_string_literal: true

require_relative '../../examples/use_cases/create_user'

RSpec.describe 'UseCase' do
  let(:current_user) { OpenStruct.new(name: :admin) }

  it 'must create user' do
    name = 'john'
    age = 33
    facade = CreateUser::Facade.new current_user: current_user

    use_case = CreateUser::UseCase.new age: age, name: name
    user = facade.exec use_case

    expect(user).to be_a(CreateUser::User)
    expect(user.saved).to be_truthy

    expect(facade.status).to eq(:green)
    expect(facade.steps.count).to eq(6)
    expect(facade.instance_values).to be_a(Hash)

    keys = %i[
      current_user current_strategy strategies
      entity exception current_class current_method bucket
      executed last_result status errors steps
    ]
    expect(facade.instance_values.keys).to include(*keys)
  end

  context 'validate name' do
    it 'Name cannot be blank' do
      facade = CreateUser::Facade.new current_user: current_user

      use_case = CreateUser::UseCase.new name: nil
      facade.exec use_case

      expect(facade.status).to eq(:red)
      expect(facade.errors).to eq(['Name cannot be blank.'])
    end

    it 'Name must contain at least 4 characters' do
      facade = CreateUser::Facade.new current_user: current_user

      use_case = CreateUser::UseCase.new name: 'leo'
      facade.exec use_case

      expect(facade.status).to eq(:red)
      expect(facade.errors).to eq(['Name must contain at least 4 characters.'])
    end
  end

  context 'validate age' do
    let(:name) { 'Chuck Norry' }

    it 'Name cannot be blank' do
      facade = CreateUser::Facade.new current_user: current_user

      use_case = CreateUser::UseCase.new name: name
      facade.exec use_case

      expect(facade.status).to eq(:red)
      expect(facade.errors).to eq(['Age must be an "Integer".'])
    end

    it 'Name must contain at least 4 characters' do
      facade = CreateUser::Facade.new current_user: current_user

      use_case = CreateUser::UseCase.new name: name, age: 17
      facade.exec use_case

      expect(facade.status).to eq(:red)
      expect(facade.errors).to eq(['Must be over 18 years old.'])
    end
  end
end
