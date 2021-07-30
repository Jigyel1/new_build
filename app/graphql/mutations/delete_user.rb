# frozen_string_literal: true

module Mutations
  class DeleteUser < BaseMutation
    argument :id, ID, required: true
    field :status, Boolean, null: true

    def resolve(id:)
      resolver = ::Users::UserDeleter.new(current_user: current_user, attributes: { id: id })
      { status: resolver.call }
    end
  end
end
