# frozen_string_literal: true

module Types
  class UsersType < BaseObject
    field :id, ID, null: true
    field :firstname, String, null: true
    field :lastname, String, null: true
    field :salutation, String, null: true
    field :department, String, null: true
    field :phone, String, null: true
  end
end
