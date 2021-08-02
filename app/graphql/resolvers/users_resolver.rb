# frozen_string_literal: true

module Resolvers
  class UsersResolver < SearchObjectBase
    scope do
      instrument('user_listing', context[:current_arguments]) { ::UsersList.all }
    end

    type Types::UserConnectionType, null: false

    option(:role_ids, type: [String]) { |scope, value| scope.where(role_id: value) }
    option(:departments, type: [String]) { |scope, value| scope.where(department: value) }
    option(:active, type: Boolean) { |scope, value| scope.where(active: value) }

    option :query, type: String, with: :apply_search, description: <<~DESC
      Supports searches on user's email, firstname, lastname, phone and role
    DESC

    option :skip, type: Int, with: :apply_skip

    def apply_search(scope, value)
      scope.where(
        "CONCAT_WS(
          ' ',
          email,
          name,
          phone,
          role)
          iLIKE ?",
        "%#{value.squish}%"
      )
    end
  end
end
