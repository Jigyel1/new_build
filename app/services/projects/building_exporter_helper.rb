# frozen_string_literal: true

module Projects
  module BuildingExporterHelper
    CSV_HEADERS = %w[ProjectNumber BuildingNumber BuildingStreet BuildingHouseNumber BuildingHouseNumberAdd
                     ZipCode City AmountOfHomes ProjectReference/LotNumber BuildingMoveInDate InfomanagerID
                     CoordinateOfProject(north) CoordinateOfProject(east) KamRegion].freeze

    private

    def building
      @_building ||= Projects::Building.find(id)
    end

    def project
      @_project ||= building.project
    end

    def address
      @_address ||= building.address
    end
  end
end
