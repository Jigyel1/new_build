# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    include ActionPolicy::GraphQL::Behaviour

    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field(
      :users,
      resolver: Resolvers::Users,
      connection: true,
      preauthorize: { record: ::User, with: ::UserPolicy, to: :index? }
    )

    field :user, resolver: Resolvers::User, authorize: { with: UserPolicy }

    field :departments, resolver: Resolvers::Departments, description: <<~DESC
      A list of available/valid departments. List available at `config/departments.yml`
    DESC

    field :roles, resolver: Resolvers::Roles, connection: true
    field :role, resolver: Resolvers::Role

    field :permissions, resolver: Resolvers::Permissions, description: <<~DESC
      A list of valid permissions for different resources with respect for individual roles`
    DESC
  end
end
