# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateCostThreshold < BaseMutation
      class UpdateCostThresholdAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :exceeding, Float, required: true
      end

      argument :attributes, UpdateCostThresholdAttributes, required: true
      field :cost_threshold, Types::AdminToolkit::CostThresholdType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::CostThresholdUpdater, :cost_threshold, attributes: attributes.to_h)
      end
    end
  end
end
