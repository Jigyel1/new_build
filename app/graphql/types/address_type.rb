# frozen_string_literal: true

module Types
  class AddressType < BaseObject
    field :id, ID, null: false
    field :street, String, null: true
    field :street_no, String, null: true
    field :zip, String, null: true
    field :city, String, null: true
  end
end
