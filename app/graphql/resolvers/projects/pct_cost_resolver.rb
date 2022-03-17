# frozen_string_literal: true

module Resolvers
  module Projects
    class PctCostResolver < BaseResolver
      class ProjectsPctCostAttributes < Types::BaseInputObject
        argument :project_id, ID, required: true

        argument :connection_cost_id, ID, required: false
        argument :connection_type, String, required: false
        argument :cost_type, String, required: false

        argument :competition_id, ID, required: false
        argument :sockets, Int, required: false, description: <<~DESC
          If not set, sockets value will be taken as 0. So your project cost will be equal
          to the connection cost(connection_cost + socket_installation_cost(0))
        DESC

        argument :project_connection_cost, Float, required: false, description: <<~DESC
          Required if the connection type selected is non standard.
        DESC
      end

      type Types::Projects::PctCostType, null: true
      argument :attributes, ProjectsPctCostAttributes, required: true

      def resolve(attributes:)
        ::Projects::ExistingPctDestroyer.new(attributes: attributes.to_h).call

        resolver = ::Projects::PctCostCalculator.new(
          attributes.to_h.merge(system_generated_payback_period: true)
        )
        resolver.call
        resolver.pct_cost
      end
    end
  end
end
