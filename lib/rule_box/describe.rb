# frozen_string_literal: true

module RuleBox
  module Describe
    def desc(description)
      @description = description
    end

    def description
      @description ||= name.gsub(/([A-Z][a-z])/) { |target| " #{target.downcase}" }.delete(':').strip
    end
  end
end
