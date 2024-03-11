# frozen_string_literal: true

Callback = ->(value) { value.to_s }
class UseCase < RuleBox::UseCase
  desc 'A small use case!'
  input :name, kind: :string, required: true, callback: Callback
  input :email, kind: :string
  input :temper, kind: :string, default: :happy, callback: Callback
  input :age, kind: :number, required: true
  output :description, detail: 'a small summary'
end

RSpec.describe RuleBox::UseCase do
  let(:schema) do
    {
      'description' => 'A small use case!',
      'inputs' => {
        'name' => { 'kind' => :string, 'required' => true },
        'email' => { 'kind' => :string },
        'temper' => { 'kind' => :string, 'default' => :happy },
        'age' => { 'kind' => :number, 'required' => true }
      },
      'outputs' => {
        'description' => { 'detail' => 'a small summary' }
      }
    }
  end

  describe 'instance methods' do
    describe '#schema' do
      it do
        use_case = UseCase.new
        expect(use_case.schema).to be_an(Hash)
        expect(use_case.schema).to eq(schema)
      end
    end
  end

  describe 'class methods' do
    describe '.schema' do
      it do
        expect(UseCase.schema).to be_an(Hash)
        expect(UseCase.schema).to eq(schema)
      end
    end
  end
end
