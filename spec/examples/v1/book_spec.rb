# frozen_string_literal: true

require_relative 'book'

RSpec.describe 'Rules of Book' do
  let(:current_errors) { [] }

  before :each do
    RuleBox::Facade.configure do |config|
      config.rescue_from(StandardError) { |error| current_errors << error.message }
      config.add_dependency(:user) do |obj|
        raise 'Must be an User' unless obj.is_a?(User)
      end
    end
  end
  after(:all) { RuleBox::Facade.clear_configuration! }

  it 'must validate user is "Leo"' do
    user = User.new
    book = Book.new
    facade = RuleBox::Facade.new(user: user)
    facade.exec :insert, book

    expect(facade.status).to eq(:red)
    expect(facade.errors.first).to eq('is not Leo')
    expect(current_errors.empty?).to be_truthy
  end
end
