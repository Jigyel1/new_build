# frozen_string_literal: true

module Types
  class RoleType < BaseObject
    field :id, ID, null: false
    field :name, String, null: true

    field :users, [Types::UserType], null: true

    def users
      BatchLoaders::AssociationLoader.for(object.class, :users).load(object)
    end
  end
end
