# frozen_string_literal: true

module Resolvers
  class RoleResolver < BaseResolver
    argument :id, ID, required: true
    type Types::RoleType, null: true

    def resolve(id:)
      ::Role.find(id)
    end
  end
end
