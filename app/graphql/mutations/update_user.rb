# frozen_string_literal: true

module Mutations
  class UpdateUser < BaseMutation
    argument :id, ID, required: true
    argument :role_id, ID, required: false
    argument :profile, GraphQL::Types::JSON, as: :profile_attributes, required: false
    argument :address, GraphQL::Types::JSON, as: :address_attributes, required: false

    field :user, Types::UserType, null: true

    def resolve(**attributes)
      resolver = ::Users::UserUpdater.new(current_user: current_user, attributes: attributes)
      resolver.call

      { user: resolver.user }
    end
  end
end
