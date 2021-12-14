# frozen_string_literal: true

module Projects
  class Importer < BaseService
    attr_accessor :file

    def call
      authorize! Project, to: :import?, with: ProjectPolicy

      with_tracking { ProjectsImporter.call(current_user: current_user, input: file) }
    end

    private

    def activity_params
      {
        action: :project_imported,
        owner: current_user,
        trackable_type: 'Project',
        parameters: { filename: file.original_filename }
      }
    end
  end
end
