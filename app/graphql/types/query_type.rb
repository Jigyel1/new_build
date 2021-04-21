# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :users, resolver: Resolvers::Users, connection: true
    field :user, resolver: Resolvers::User

    field :departments, resolver: Resolvers::Departments, description: <<~DESC
      Get a list of available/valid departments. List available at `config/departments.yml`
    DESC

    field :roles, resolver: Resolvers::Roles, connection: true
    field :role, resolver: Resolvers::Role
  end
end
