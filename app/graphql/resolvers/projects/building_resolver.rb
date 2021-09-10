# frozen_string_literal: true

module Resolvers
  module Projects
    class BuildingResolver < BaseResolver
      argument :id, ID, required: true
      type Types::Projects::BuildingType, null: true

      def resolve(id:)
        ::Projects::Building.find(id)
      end
    end
  end
end
