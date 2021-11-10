# frozen_string_literal: true

require 'csv'

module Projects
  class BuildingExporter < BaseService
    attr_accessor :id

    def call
      authorize! Project, to: :update?
    end

    private

    def building
      Projects::Building.find(id)
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
