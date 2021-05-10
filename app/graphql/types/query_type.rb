# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include ActionPolicy::GraphQL::Behaviour

    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field(
      :users,
      resolver: Resolvers::UsersResolver,
      connection: true,
      preauthorize: { record: ::User, with: ::UserPolicy, to: :index? }
    )

    field :user, resolver: Resolvers::UserResolver, authorize: { with: UserPolicy }

    field :departments, resolver: Resolvers::DepartmentsResolver, description: <<~DESC
      A list of available/valid departments. List available at `config/departments.yml`
    DESC

    field(
      :roles,
      resolver: Resolvers::RolesResolver,
      connection: true,
      preauthorize: { record: ::Role, with: ::RolePolicy, to: :index? }
    )
    field :role, resolver: Resolvers::RoleResolver, authorize: { with: RolePolicy }

    field :permissions, resolver: Resolvers::PermissionsResolver, description: <<~DESC
      A list of valid permissions for different resources with respect for individual roles`
    DESC

    field :activities, resolver: Resolvers::ActivitiesResolver
    field :activity_actions, resolver: Resolvers::ActivityActionsResolver
  end
end
