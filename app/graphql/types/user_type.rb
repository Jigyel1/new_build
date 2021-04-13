# frozen_string_literal: true

module Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :email, String, null: true
    field :name, String, null: true

    def name
      [object.firstname, object.lastname].join(' ')
    end
  end
end
