# frozen_string_literal: true

class UseCaseAdmin < UseCaseBase
  add_dependency :admin do |admin|
    'Must pass Admin instance!' unless admin.is_a? Admin
  end
end
