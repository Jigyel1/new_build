# frozen_string_literal: true

module Types
  module Projects
    class BuildingType < BaseObject
      field :id, ID, null: false
      field :name, String, null: true
      field :apartments_count, Int, null: true
      field :move_in_starts_on, String, null: true
      field :move_in_ends_on, String, null: true

      field :assignee, Types::UserType, null: true
      field :address, Types::AddressType, null: true
    end
  end
end
