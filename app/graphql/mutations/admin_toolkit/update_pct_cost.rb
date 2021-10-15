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
        super(::AdminToolkit::PctCostUpdater, :pct_cost, attributes: attributes.to_h)
      end
    end
  end
end
