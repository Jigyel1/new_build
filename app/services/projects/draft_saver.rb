# frozen_string_literal: true

module Projects
  class DraftSaver < BaseService
    def call
      with_tracking(activity_id = SecureRandom.uuid) do
        project.update!(draft_version: attributes[:draft_version])
        Activities::ActivityCreator.new(activity_id: activity_id, **activity_params).call
      end
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
