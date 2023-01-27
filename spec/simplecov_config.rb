# frozen_string_literal: true

require 'simplecov'

SimpleCov.command_name 'RSpec'
SimpleCov.start do
  add_filter '/spec'
end
