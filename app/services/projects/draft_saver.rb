# frozen_string_literal: true

module Projects
  class DraftSaver < BaseService
    def call
      authorize! project, to: :update?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
        project.update!(draft_version: attributes[:draft_version])

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def project
      @_project ||= Project.find(attributes.delete(:id))
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_draft_version,
        owner: current_user,
        trackable: project,
        parameters: attributes
      }
    end
  end
end
