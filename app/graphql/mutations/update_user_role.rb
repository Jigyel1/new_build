# frozen_string_literal: true

module Mutations
  class UpdateUserRole < BaseMutation
    argument :id, ID, required: true
    argument :roleId, ID, required: true

    field :user, Types::UserType, null: true

    def resolve(**attributes)
      resolver = ::Users::RoleUpdater.new(current_user: current_user, attributes: attributes)
      resolver.call

      { user: resolver.user }
    end
  end
end
