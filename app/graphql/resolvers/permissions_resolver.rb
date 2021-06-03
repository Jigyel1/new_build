# frozen_string_literal: true

module Resolvers
  class PermissionsResolver < SearchObjectBase
    scope { Rails.application.config.role_permissions }

    type GraphQL::Types::JSON, null: false
  end
end
