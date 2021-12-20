# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateProjectCost < BaseMutation
      class UpdateProjectCostAttributes < Types::BaseInputObject
        argument :standard, Float, required: false
        argument :arpu, Float, required: false
        argument :socket_installation_rate, Float, required: false

        # TODO: Descriptions to be added to these fields after getting some context from BA.
        argument :cpe_hfc, Float, required: false
        argument :cpe_ftth, Float, required: false
        argument :olt_cost_per_customer, Float, required: false
        argument :old_cost_per_unit, Float, required: false
        argument :patching_cost, Float, required: false
        argument :mrc_standard, Float, required: false
        argument :mrc_high_tiers, Float, required: false
        argument :high_tiers_product_share, Float, required: false
        argument :ftth_cost, Float, required: false
        argument :hfc_payback, Int, required: false
        argument :ftth_payback, Int, required: false
      end

      argument :attributes, UpdateProjectCostAttributes, required: true
      field :project_cost, Types::AdminToolkit::ProjectCostType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::ProjectCostUpdater, :project_cost, attributes: attributes.to_h)
      end
    end
  end
end
