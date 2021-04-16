# frozen_string_literal: true

module Mutations
  class UpdateUserStatus < BaseMutation
    argument :id, ID, required: true
    argument :active, Boolean, required: true

    field :user, Types::UserType, null: true

    def resolve(**attributes)
      resolver = ::Users::StatusUpdater.new(current_user: current_user, attributes: attributes)
      resolver.call

      { user: resolver.user }
    end
  end
end
