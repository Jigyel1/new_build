# frozen_string_literal: true

module Resolvers
  class PermissionsResolver < SearchObjectBase
    scope { ::Role::PERMISSIONS }

    type GraphQL::Types::JSON, null: false
  end
end
