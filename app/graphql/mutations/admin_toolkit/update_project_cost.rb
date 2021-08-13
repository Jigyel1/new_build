# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateProjectCost < BaseMutation
      class UpdateProjectCostAttributes < Types::BaseInputObject
        argument :standard, Float, required: false
        argument :arpu, Float, required: false
        argument :socket_installation_rate, Float, required: false
      end

      argument :attributes, UpdateProjectCostAttributes, required: true
      field :project_cost, Types::AdminToolkit::ProjectCostType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::ProjectCostUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { project_cost: resolver.project_cost }
      end
    end
  end
end
