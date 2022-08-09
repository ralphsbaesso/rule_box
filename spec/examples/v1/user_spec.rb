# frozen_string_literal: true

require_relative 'user'

RSpec.describe 'Rules to User' do
  before :each do
    RuleBox.configure do |config|
      config.rescue_from Exception do |facade|
        facade.add_error 'Ops, ocorreu um erro!'
      end
    end
  end

  after(:all) { RuleBox::Facade.clear_configuration! }

  it 'validate name of user' do
    user = User.new
    user.name = 'Beltrano'
    user.age = 19

    facade = RuleBox::Facade.new
    facade.exec :insert, user
    expect(facade.status).to eq(:green)
  end

  it 'must throws error' do
    user = User.new
    user.name = 'name'
    user.age = 19
    user.throws_error = true

    facade = RuleBox::Facade.new
    facade.exec :insert, user

    errors = facade.errors
    expect(errors.count).to eq(1)
    expect(errors.first).to eq('Ops, ocorreu um erro!')
  end

  it 'show current method' do
    user = User.new
    user.name = 'name'
    user.age = 20

    facade = RuleBox::Facade.new
    expect(facade.current_method).to be_nil
    facade.exec :insert, user
    expect(facade.current_method).to eq(:insert)
  end

  context 'with dynamic rules' do
    it 'must check one error' do
      user = User.new
      user.name = 'leo'
      user.age = 19

      facade = RuleBox::Facade.new
      facade.exec :check, user
      expect(facade.errors.count).to eq(1)
      expect(facade.errors.first).to eq('Nome deve conter pelo menos 4 caracteres')
    end
  end
end
