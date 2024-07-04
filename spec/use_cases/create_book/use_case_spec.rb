# frozen_string_literal: true

require_relative '../../examples/load'

RSpec.describe CreateBook::UseCase do
  let(:user) { User.new }

  it 'must create Book' do
    name = 'the best book'
    code = '123456'

    use_case = CreateBook::UseCase.new user: user
    output = use_case.exec name: name, code: code

    expect(output).to be_a(Hash)
    expect(output[:status]).to eq('ok')

    book = output[:data]
    expect(book).to be_an(Book)
    expect(book.name).to eq(name)
    expect(book.code).to eq(code)
  end

  context 'with error' do
    it 'must return error code' do
      name = 'the best book'
      code = nil

      use_case = CreateBook::UseCase.new user: user
      output = use_case.exec name: name, code: code

      expect(output[:status]).to eq('error')
      expect(output[:errors]).to eq(['Invalid code.'])
    end
  end
end
