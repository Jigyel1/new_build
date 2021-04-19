# frozen_string_literal: true

module Types
  class RoleType < BaseObject
    field :id, ID, null: false
    field :name, String, null: true

    field :users, [Types::UserType], null: true
  end
end
