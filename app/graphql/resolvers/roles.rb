# frozen_string_literal: true

module Resolvers
  class Roles < SearchObjectBase
    scope { ::Role.all }

    type Types::RoleConnectionWithTotalCountType, null: false
  end
end
