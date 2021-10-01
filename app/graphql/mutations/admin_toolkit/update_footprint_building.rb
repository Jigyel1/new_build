# frozen_string_literal: true

module Mutations
  module AdminToolkit
    class UpdateFootprintBuilding < BaseMutation
      class UpdateFootprintBuildingAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :max, Int, required: true
      end

      argument :attributes, UpdateFootprintBuildingAttributes, required: true
      field :footprint_building, Types::AdminToolkit::FootprintBuildingType, null: true

      def resolve(attributes:)
        super(::AdminToolkit::FootprintBuildingUpdater, :footprint_building, attributes: attributes.to_h)
      end
    end
  end
end
