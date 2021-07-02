# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdatePctCost < BaseMutation
      class UpdatePctCostAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :max, Int, required: true
      end

      argument :attributes, UpdatePctCostAttributes, required: true
      field :pct_cost, Types::AdminToolkit::PctCostType, null: true

      def resolve(attributes:)
        resolver = ::AdminToolkit::PctCostUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { pct_cost: resolver.pct_cost }
      end
    end
  end
end
