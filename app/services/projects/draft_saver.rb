# frozen_string_literal: true

module Projects
  class DraftSaver < BaseService
    def call
      with_tracking { project.update!(draft_version: attributes[:draft_version]) }
    end

    def project
      @_project ||= Project.find(attributes.delete(:id))
    end

    def activity_params
      {
        action: :project_draft_version,
        owner: current_user,
        trackable: project,
        parameters: { project_name: project.name }
      }
    end
  end
end
