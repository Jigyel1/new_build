# frozen_string_literal: true

module Types
  module AdminToolkit
    class FootprintValueType < BaseObject
      field :id, ID, null: true
      field :project_type, String, null: true
      field :footprint_building, FootprintBuildingType, null: true
      field :footprint_type, FootprintTypeType, null: true

      def footprint_building
        BatchLoaders::AssociationLoader
          .for(
            ::AdminToolkit::FootprintValue,
            :footprint_building
          )
          .load(object)
      end

      def footprint_type
        BatchLoaders::AssociationLoader
          .for(
            ::AdminToolkit::FootprintValue,
            :footprint_type
          )
          .load(object)
      end
    end
  end
end
