# frozen_string_literal: true

module RuleBox::Util
  class << self
    def camelize(string)
      strings = string.split('_')
      new_string = ''
      strings.each do |word|
        new_string += word[0].upcase + word[1..-1]
      end
      new_string.gsub('/', '::')
    end
  end
end
