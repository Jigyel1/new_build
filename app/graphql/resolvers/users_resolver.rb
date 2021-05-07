# frozen_string_literal: true

module Resolvers
  class UsersResolver < SearchObjectBase
    scope do
      instrument('user_listing', context[:current_arguments]) { ::UsersList.all }
    end

    type Types::UserConnectionType, null: false

    option :role_ids, type: [String], with: :apply_role_filter
    option :departments, type: [String], with: :apply_department_filter
    option :active, type: Boolean, with: :apply_status_filter
    option :query, type: String, with: :apply_search, description: <<~DESC
      Supports searches on user's email, firstname, lastname, phone and role
    DESC

    option :first, type: Int, with: :apply_first
    option :skip, type: Int, with: :apply_skip

    def apply_role_filter(scope, value)
      scope.where(role_id: value)
    end

    def apply_department_filter(scope, value)
      scope.where(department: value)
    end

    def apply_status_filter(scope, value)
      scope.where(active: value)
    end

    def apply_first(scope, value)
      scope.limit(value)
    end

    def apply_skip(scope, value)
      scope.offset(value)
    end

    def apply_search(scope, value)
      scope.where(
        "CONCAT_WS(
          ' ',
          email,
          name,
          phone,
          role)
          iLIKE ?",
        "%#{value.strip}%"
      )
    end
  end
end
