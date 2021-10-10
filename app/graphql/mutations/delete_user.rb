# frozen_string_literal: true

module Mutations
  class DeleteUser < BaseMutation
    class DeleteUserAttributes <  Types::BaseInputObject
      argument :id, ID, required: true
      argument :assignee_id, ID, required: false, description: <<~DESC
        All projects & tasks belonging to the user being deleted will be re assigned to this user.
      DESC

      argument :region_mappings, [GraphQL::Types::JSON], required: false, description: <<~DESC
        Send request in this format - [{ kam_region_id: :kam_id }, { ... } ]
        Only applicable for KAMs.
      DESC

      argument :investor_mappings, [GraphQL::Types::JSON], required: false, description: <<~DESC
        Send request in this format - [{ kam_investor_id: :kam_id }, { ... } ]
        Only applicable for KAMs.
      DESC
    end

    argument :attributes, DeleteUserAttributes, required: true
    field :status, Boolean, null: true

    def resolve(attributes:)
      resolver = ::Users::UserDeleter.new(current_user: current_user, attributes: attributes.to_h)
      { status: resolver.call }
    end
  end
end
