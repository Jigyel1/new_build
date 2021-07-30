# frozen_string_literal: true

module Types
  module AdminToolkit
    class FootprintValueType < BaseObject
      field :id, ID, null: true
      field :project_type, String, null: true
      field :footprint_building, FootprintBuildingType, null: true
      field :footprint_type, FootprintTypeType, null: true
    end
  end
end
