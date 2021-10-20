# frozen_string_literal: true

module Mutations
  class DeleteUser < BaseMutation
    class DeleteUserAttributes <  Types::BaseInputObject
      argument :id, ID, required: true
      argument :assignee_id, ID, required: false, description: <<~DESC
        All projects & tasks belonging to the user being deleted will be re assigned to this user.
      DESC

      argument :region_mappings, [GraphQL::Types::JSON], required: false, description: <<~DESC
        Send request in this format -
        [
          { kamRegionId: "b9371473-4259-4180-8d4d-c4906c0d6e7f", :kamId: "063ba163-2446-4198-9b3d-90133c163db0" },
          { ... }
        ]
        Only applicable for KAMs.
      DESC

      argument :investor_mappings, [GraphQL::Types::JSON], required: false, description: <<~DESC
        Send request in this format -
         [
           { kamInvestorId: "b9371473-4259-4180-8d4d-c4906c0d6e7f", :kamId: "063ba163-2446-4198-9b3d-90133c163db0" },
           { ... }
         ]
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
