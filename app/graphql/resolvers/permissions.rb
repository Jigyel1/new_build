# frozen_string_literal: true

module Resolvers
  class Permissions < SearchObjectBase
    scope { ::Role::PERMISSIONS }

    type GraphQL::Types::JSON, null: false
  end
end
