# frozen_string_literal: true

module Mutations
  class UpdateUserRole < BaseMutation
    class UpdateRoleAttributes < Types::BaseInputObject
      argument :id, ID, required: true
      argument :role_id, ID, required: true
    end

    argument :attributes, UpdateRoleAttributes, required: true
    field :user, Types::UserType, null: true

    def resolve(attributes:)
      super(::Users::RoleUpdater, :user, attributes: attributes.to_h)
    end
  end
end
