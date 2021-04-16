# frozen_string_literal: true

module Resolvers
  class Users < SearchObjectBase
    scope { ::User.all }

    type Types::UserConnectionWithTotalCountType, null: false

    option :role_ids, type: [ID], with: :apply_role_filter
    option :departments, type: [String], with: :apply_department_filter
    option :active, type: Boolean, with: :apply_status_filter
    option :query, type: String, with: :apply_search, description: <<~DESC
      Supports searches on user's email, firstname, lastname, phone and role
    DESC

    option :first, type: Int, with: :apply_first
    option :skip, type: Int, with: :apply_skip

    # pagination
    # https://www.howtographql.com/graphql-ruby/8-pagination/
    # https://www.youtube.com/watch?v=lNtQbn7qN-8
    #
    # https://graphqlme.com/2017/09/24/graphql-connections-rails/ - CHECK THIS FIRST ON PAGINATION!
    #
    # sorting
    # https://github.com/howtographql/graphql-ruby/blob/master/app/graphql/resolvers/links_search.rb
    # lets give sorting for name, email and phone

    # for projects pagination - refer to this https://graphql-ruby.org/relay/connections.html

    def apply_role_filter(scope, value)
      return scope if empty?(value)

      scope.includes(:role).where(roles: { id: value })
    end

    def apply_department_filter(scope, value)
      return scope if empty?(value)

      scope.includes(:profile).where(profiles: { department: value })
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
      scope
        .joins(:profile, :role)
        .where(
          "CONCAT_WS(
            ' ',
            telco_uam_users.email,
            profiles.firstname,
            profiles.lastname,
            profiles.phone,
            roles.name)
            iLIKE ?",
          "%#{value.strip}%"
        )
    end
  end
end
