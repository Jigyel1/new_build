# frozen_string_literal: true

module Resolvers
  module Projects
    class PctCostResolver < BaseResolver
      class ProjectsPctCostAttributes < Types::BaseInputObject
        argument :project_id, ID, required: true
        argument :competition_id, ID, required: false
        argument :lease_cost_only, Boolean, required: false, description: <<~DESC
          To calculate overall project's PCT costs, there are additional dependencies on the admin toolkit
          where if some of the parameters are not set will throw errors or return in-accurate calculations.
          So to just get the lease cost, set this flag as true.
        DESC

        argument :project_connection_cost, Float, required: false, description: <<~DESC
          Required for complex projects. Optional for marketing_only & irrelevant projects. If not sent,
          0 will be used as it's default value for calculation.
        DESC
      end

      type Types::Projects::PctCostType, null: true
      argument :attributes, ProjectsPctCostAttributes, required: true

      def resolve(attributes:)
        resolver = ::Projects::PctCostCalculator.new(
          attributes.to_h.merge(system_generated_payback_period: true)
        )
        resolver.call
        resolver.pct_cost
      end
    end
  end
end
