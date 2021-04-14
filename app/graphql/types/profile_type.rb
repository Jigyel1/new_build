# frozen_string_literal: true

module Types
  class ProfileType < BaseObject
    field :id, ID, null: false
    field :firstname, String, null: true
    field :lastname, String, null: true
    field :salutation, String, null: true
    field :phone, String, null: true
    field :department, String, null: true
  end
end
