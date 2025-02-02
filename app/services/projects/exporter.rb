# frozen_string_literal: true

require 'csv'

module Projects
  class Exporter < BaseService
    attr_accessor :ids

    def call
      authorize! Project, to: :update?

      string_io = CSV.generate(headers: true) do |csv|
        csv << Exports::PrepareHeaders.new(csv_headers: csv_headers, projects: projects).call

        projects.each do |project|
          csv << Exports::PrepareRow.new(csv_headers: csv_headers, project: project).call
        end
      end

      url(string_io)
    end

    private

    def projects
      @_projects ||= Project.where(id: ids).order(:external_id)
    end

    def url(csv)
      current_user.projects_download.attach(
        io: StringIO.new(csv),
        filename: 'projects.csv',
        content_type: 'application/csv'
      ).then do |attached|
        attached && url_for(current_user.projects_download)
      end
    end

    def csv_headers
      @_csv_headers ||= FileParser.parse { 'app/services/projects/csv_headers.yml' }
    end
  end
end
