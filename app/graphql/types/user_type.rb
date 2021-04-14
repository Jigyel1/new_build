# frozen_string_literal: true

module Types
  class UserType < BaseObject
    field :id, ID, null: false
    field :email, String, null: true
    field :name, String, null: true
    field :role_id, ID, null: true

    field :role, Types::RoleType, null: true
    field :profile, Types::ProfileType, null: true
    field :address, Types::AddressType, null: true
  end
end
