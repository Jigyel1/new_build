# frozen_string_literal: true

module Projects
  class BuildingManualBuilder < BaseService
    attr_accessor :project, :buildings_count

    def call
      buildings_count == project.site_address.count ? create_building : raise('Mismatch')
    end

    private

    def create_building
      1.upto(buildings_count) do |index|
        site_address = project.site_address[index - 1]

        project.buildings.build(
          name: site_address['name'],
          assignee: project.assignee,
          apartments_count: site_address['apartments_count'],
          move_in_starts_on: site_address['move_in_starts_on'],
          address_attributes: site_address['address']
        )
      end
    end
  end
end
