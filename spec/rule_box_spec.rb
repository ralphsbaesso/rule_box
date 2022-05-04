# frozen_string_literal: true

RSpec.describe RuleBox do
  it 'has a version number' do
    expect(RuleBox::VERSION).not_to be nil
  end

  context '.show_mapped_classes' do
    it 'show class using RuleBox::Mapper' do
      User.include RuleBox::Mapper
      Book.include RuleBox::Mapper

      classes = RuleBox.show_mapped_classes
      expect(classes).to include(User)
      expect(classes).to include(Book)
    end
  end
end
