# frozen_string_literal: true

module Types
  class UsersListType < BaseObject
    field :id, ID, null: true
    field :name, String, null: true
    field :email, String, null: true
    field :active, Boolean, null: true
    field :role, String, null: true
    field :phone, String, null: true
    field :department, String, null: true
  end
end
