# frozen_string_literal: true

module Projects
  class BuildingManualBuilder < BaseService
    attr_accessor :project, :buildings_count

    def call
      buildings_count == project.site_address.count ? create_building : raise('Mismatch')
    end

    private

    def create_building
      1.upto(buildings_count) do |_index|
        project.site_address.each do |site_address|
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
end
