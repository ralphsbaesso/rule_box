# frozen_string_literal: true

Callback = lambda(&:to_s)
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

class UseCase1 < RuleBox::UseCase; end
class Input1 < RuleBox::Input; end
class UseCase2 < RuleBox::UseCase; end

class Input2 < RuleBox::Input
  add :last_name
end

class UseCase3 < RuleBox::UseCase; end

class Input3 < RuleBox::Input
  add :input
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

  describe 'custom UseCase' do
    context 'add Input by default Input and after custom Input' do
      it 'must throw exception' do
        UseCase1.inputs :name, :email
        expect { UseCase1.input Input1 }.to raise_error('resource Input already defined')
      end
    end

    context 'add Input by custom Input and after default Input' do
      it do
        UseCase2.input Input2
        expect do
          UseCase2.input do |i|
            i.add :name, required: true
            i.add :first_name, required: true
          end
        end.to_not raise_error

        input = UseCase2::Input.new
        expect(input).to respond_to(:last_name)
        expect(input).to respond_to(:name)
        expect(input).to respond_to(:first_name)
        expect(input).to be_an(Input2)
      end
    end

    context 'add Input by custom Input and with block' do
      it do
        expect do
          UseCase3.input Input3 do |i|
            i.add :input1
            i.add :input2
          end
        end.to_not raise_error

        input = UseCase3::Input.new
        expect(input).to respond_to(:input)
        expect(input).to respond_to(:input1)
        expect(input).to respond_to(:input2)
        expect(input).to be_an(Input3)
      end
    end
  end
end
