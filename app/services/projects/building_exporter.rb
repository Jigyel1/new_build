# frozen_string_literal: true

require 'csv'

module Projects
  class BuildingExporter < BaseService
    include BuildingExportHelper
    attr_accessor :id

    def call
      authorize! Project, to: :update?

      string_io = CSV.generate(headers: true) do |csv|
        csv << CSV_HEADERS
        csv << values
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
