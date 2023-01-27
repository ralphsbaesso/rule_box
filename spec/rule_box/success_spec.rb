# frozen_string_literal: true

RSpec.describe RuleBox::Result::Success do
  context 'instance methods' do
    context '#instance_values' do
      it do
        result = RuleBox::Result::Success.new
        expect(result.instance_values).to be_a(Hash)
        expect(result.instance_values.keys).to eq(%w[status data errors meta])
      end
    end

    context '#status' do
      context 'base' do
        it do
          result = RuleBox::Result.new
          expect { result.status }.to raise_error('Must implement this method!')
        end
      end

      context 'Error' do
        it do
          result = RuleBox::Result::Error.new
          expect(result.status).to eq('error')
        end
      end

      context 'Neutral' do
        it do
          result = RuleBox::Result::Neutral.new
          expect(result.status).to eq('neutral')
        end
      end

      context 'Success' do
        it do
          result = RuleBox::Result::Success.new
          expect(result.status).to eq('ok')
        end
      end
    end

    context '#concat!' do
      it 'success by other success result' do
        first_data = :first_data
        first_meta = :first_meta
        first_success = RuleBox::Result::Success.new(data: first_data, meta: first_meta)

        success = RuleBox::Result::Success.new
        success.concat!(first_success)

        expect(success.status).to eq('ok')
        expect(success.data).to eq(first_data)
        expect(success.meta).to eq(first_meta)
      end

      it 'neutral by other success result' do
        first_data = :first_data
        first_meta = :first_meta
        first_success = RuleBox::Result::Success.new(data: first_data, meta: first_meta)

        neutral = RuleBox::Result::Neutral.new
        neutral.concat!(first_success)

        expect(neutral.status).to eq('neutral')
        expect(neutral.data).to eq(first_data)
        expect(neutral.meta).to eq(first_meta)
      end

      it 'error by other success result' do
        first_data = :first_data
        first_meta = :first_meta
        first_success = RuleBox::Result::Success.new(data: first_data, meta: first_meta)

        error = RuleBox::Result::Error.new
        error.concat!(first_success)

        expect(error.status).to eq('error')
        expect(error.data).to eq(first_data)
        expect(error.meta).to eq(first_meta)
      end

      it 'success by other error result' do
        first_data = :first_data
        first_meta = :first_meta
        errors = %i[any_error other_error]
        error_result = RuleBox::Result::Error.new data: first_data,
                                                  meta: first_meta,
                                                  errors: errors

        first_success = RuleBox::Result::Success.new
        first_success.concat!(error_result)

        expect(first_success.status).to eq('ok')
        expect(first_success.data).to eq(first_data)
        expect(first_success.meta).to eq(first_meta)
        expect(first_success.errors).to eq(errors)

        second_success = RuleBox::Result::Success.new
        second_success.concat!(error_result, skips: :errors)

        expect(second_success.status).to eq('ok')
        expect(second_success.data).to eq(first_data)
        expect(second_success.meta).to eq(first_meta)
        expect(second_success.errors).to_not eq(errors)

        third_success = RuleBox::Result::Success.new
        third_success.concat!(error_result, skips: %i[meta errors])

        expect(third_success.status).to eq('ok')
        expect(third_success.data).to eq(first_data)
        expect(third_success.meta).to_not eq(first_meta)
        expect(third_success.errors).to_not eq(errors)
      end

      it 'must merge arguments' do
        data1 = { name: 'john' }
        meta1 = [1, 2, 3]
        first_result = RuleBox::Result.new(data: data1, meta: meta1)

        data2 = { last_name: 'givens' }
        meta2 = [4, 5, 6]
        second_result = RuleBox::Result.new(data: data2, meta: meta2)
        second_result.concat!(first_result)

        expect(second_result.data).to eq(data1.merge(data2))
        expect(second_result.meta).to eq(meta2 + meta1)
      end
    end
  end
end
