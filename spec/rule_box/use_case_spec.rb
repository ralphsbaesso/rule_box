# frozen_string_literal: true

Callback = ->(value) { value.to_s }
class UseCase < RuleBox::UseCase
  desc 'A small use case!'
  input do |i|
    i.add :name, kind: :string, required: true, callback: Callback
    i.add :email, kind: :string
    i.add :temper, kind: :string, default: :happy, callback: Callback
    i.add :age, kind: :number, required: true
  end
  output do |o|
    o.add :description, detail: 'a small summary'
  end
end

RSpec.describe RuleBox::UseCase do
  let(:schema) do
    {
      'description' => 'A small use case!',
      'dependencies' => {},
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
