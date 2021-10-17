# frozen_string_literal: true

module Projects
  class Updater < BaseService
    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        project.update!(attributes)
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def project
      @project ||= ::Project.find(attributes.delete(:id))
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :project_updated,
        owner: current_user,
        trackable: project,
        parameters: { status: attributes['status'], project_name: project.name }
      }
    end
  end
end
