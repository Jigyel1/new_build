# frozen_string_literal: true

module Resolvers
  class RolesResolver < SearchObjectBase
    scope { ::Role.all }

    type Types::RoleConnectionType, null: false
  end
end
