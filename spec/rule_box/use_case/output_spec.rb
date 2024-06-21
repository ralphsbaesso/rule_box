# frozen_string_literal: true

class Output < RuleBox::UseCase::Output
  data_accessor :status, desc: 'return status', &->(v) { v.to_s }
  data_accessor :messages, default: [], desc: 'return info messages'
  data_accessor :meta, default: {}
end

class OutputUseCase < RuleBox::UseCase
  outputs :name, :age, :job
end

RSpec.describe RuleBox::UseCase::Output do
  it 'must set default data' do
    output = Output.new(status: :success)
    expect(output.status).to eq('success')
    expect(output.messages).to eq([])
    expect(output.meta).to eq({})
  end

  context 'instance methods' do
    context '#schema' do
      it do
        output = Output.new
        expect(output.schema).to be_a(Hash)
        expect(output.schema.keys).to include('status', 'messages', 'meta')
        expect(output.schema)
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
          output = OutputUseCase::Output.new
          expect(output.schema).to be_a(Hash)
          expect(output.schema.keys).to include('name', 'age', 'job')
        end
      end
    end
  end
end
