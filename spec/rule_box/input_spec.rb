# frozen_string_literal: true

class Input < RuleBox::Input
  data_accessor :status, desc: 'return status', &lambda(&:to_s)
  data_accessor :messages, default: [], desc: 'return info messages'
  data_accessor :meta, default: {}
end

class InputUseCase < RuleBox::UseCase
  inputs :name, :age, :job
end

RSpec.describe RuleBox::Input do
  context 'instance methods' do
    context '#schema' do
      it do
        input = Input.new
        expect(input.schema).to be_a(Hash)
        expect(input.schema.keys).to include('status', 'messages', 'meta')
        expect(input.schema)
          .to eq({
                   'messages' => {
                     'default' => [],
                     'desc' => 'return info messages'
                   },
                   'meta' => {
                     'default' => {}
                   },
                   'status' => {
                     'desc' => 'return status'
                   }
                 })
      end

      context 'dynamic' do
        it do
          input = InputUseCase::Input.new
          expect(input.schema).to be_a(Hash)
          expect(input.schema.keys).to include('name', 'age', 'job')
        end
      end
    end
  end
end
