# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class ProjectCostResolver < BaseResolver
      type Types::AdminToolkit::ProjectCostType, null: true

      def resolve(id: nil)
        ::AdminToolkit::ProjectCost.instance
      end
    end
  end
end
