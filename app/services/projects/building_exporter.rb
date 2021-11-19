# frozen_string_literal: true

require 'csv'

module Projects
  class BuildingExporter < BaseService
    attr_accessor :id

    def call
      authorize! Project, to: :update?

      string_io = CSV.generate(headers: true) do |csv|
        csv << Exports::PrepareBuildingHeaders.new(csv_headers: csv_headers,
                                                   building: building,
                                                   building_project: building_project).call
        csv << Exports::PrepareBuildingRow.new(csv_headers: csv_headers,
                                               building: building,
                                               building_project: building_project).call
      end

      url(string_io)
    end

    private

    def building
      @_building ||= Projects::Building.find(id).include(:project, :address)
    end

    def building_project
      @building_project ||= building.project
    end

    def building_address
      @building_address ||= building.address
    end

    def url(csv)
      current_user.building_download.attach(
        io: StringIO.new(csv),
        filename: 'projects.csv',
        content_type: 'application/csv'
      ).then do |attached|
        attached && url_for(current_user.building_download)
      end
    end

    def csv_headers
      @_csv_headers ||= FileParser.parse { 'app/services/projects/csv_headers.yml' }
    end
  end
end
