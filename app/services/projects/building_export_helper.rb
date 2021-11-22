# frozen_string_literal: true

module Projects
  module BuildingExportHelper
    CSV_HEADERS = %w[ProjectNumber BuildingNumber BuildingStreet BuildingHouseNumber BuildingHouseNumberAdd
                     ZipCode City AmountOfHomes ProjectReference/LotNumber BuildingMoveInDate InfomanagerID
                     CoordinateOfProject(north) CoordinateOfProject(east) KamRegion].freeze

    def values # rubocop:disable Metrics/AbcSize
      [
        project.external_id,
        building.external_id,
        address.street,
        address.street_no,
        address.street_no.last,
        address.zip,
        address.city,
        building.apartments_count,
        project.lot_number,
        building.move_in_starts_on,
        project.internal_id,
        project.coordinate_north,
        project.coordinate_east,
        project.kam_region
      ]
    end

    private

    def building
      @_building ||= Projects::Building.find(id)
    end

    def project
      @project ||= building.project
    end

    def address
      @address ||= building.address
    end
  end
end

