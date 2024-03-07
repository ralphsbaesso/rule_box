# frozen_string_literal: true

class Output < RuleBox::UseCase::Output
  data_accessor :status, callback: ->(v) { v.to_s }, desc: 'return status'
  data_accessor :messages, default: [], desc: 'return info messages'
  data_accessor :meta, default: {}
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
    end
  end
end
