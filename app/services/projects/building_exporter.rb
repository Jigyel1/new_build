# frozen_string_literal: true

require 'csv'

module Projects
  class BuildingExporter < BaseService
    include BuildingExporterHelper
    attr_accessor :id

    def call # rubocop:disable Metrics/AbcSize
      authorize! Project, to: :update?

      string_io = CSV.generate(headers: true) do |csv|
        csv << CSV_HEADERS
        csv << [
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
          project.kam_region.try(:name)
        ]
      end

      url(string_io)
    end

    def url(csv)
      current_user.building_download.attach(
        io: StringIO.new(csv),
        filename: 'building.csv',
        content_type: 'application/csv'
      ).then do |attached|
        attached && url_for(current_user.building_download)
      end
    end
  end
end
