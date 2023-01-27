# frozen_string_literal: true

class ValidateDocument < RuleBox::Strategy
end

RSpec.describe RuleBox::Strategy do
  context '.description' do
    it 'without use "desc" method' do
      expect(ValidateDocument.description).to eq('validate document')
    end

    it 'with use "desc" method' do
      description = 'will validate document by client rules.'
      ValidateDocument.desc description
      expect(ValidateDocument.description).to eq(description)
    end
  end
end
