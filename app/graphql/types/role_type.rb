# frozen_string_literal: true

module Types
  class RoleType < BaseObject
    field :id, ID, null: false
    field :name, String, null: true
  end
end
