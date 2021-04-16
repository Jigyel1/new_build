# frozen_string_literal: true

module Mutations
  class DeleteUser < BaseMutation
    argument :id, ID, required: true

    field :status, Boolean, null: true

    def resolve(**attributes)
      resolver = ::Users::UserDeleter.new(current_user: current_user, attributes: attributes)

      { status: resolver.call }
    end
  end
end
