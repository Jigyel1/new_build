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
      resolver = ::Users::RoleUpdater.new(current_user: current_user, attributes: attributes)
      resolver.call

      { user: resolver.user }
    end
  end
end
