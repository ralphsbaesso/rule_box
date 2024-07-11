# frozen_string_literal: true

class UseCaseAdmin < UseCaseBase
  dependency do |d|
    d.add :admin, validate: ->(admin) { InvalidDependency.new('Must pass Admin instance!') unless admin.is_a? Admin }
  end
end
