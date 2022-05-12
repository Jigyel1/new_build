# frozen_string_literal: true

module Projects
  class BuildingManualBuilder < BaseService
    attr_accessor :project, :buildings_count

    def call
      buildings_count == project.site_address.count ? create_building : raise('Mismatch')
    end

    private

    def create_building # rubocop:disable Metrics/AbcSize
      1.upto(buildings_count) do |index|
        project.buildings.build(
          name: project.site_address[index - 1]['name'],
          apartments_count: project.site_address[index - 1]['apartments_count'],
          move_in_starts_on: project.site_address[index - 1]['move_in_starts_on'],
          address_attributes: project.site_address[index - 1]['address']
        )
      end
    end
  end
end
