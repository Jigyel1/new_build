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
        resolver = ::AdminToolkit::FootprintBuildingUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call

        { footprint_building: resolver.footprint_building }
      end
    end
  end
end
