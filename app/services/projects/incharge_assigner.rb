# frozen_string_literal: true

module Projects
  class InchargeAssigner < BaseService
    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        project.update!(incharge_id: attributes[:incharge_id])
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :incharge_assigned,
        owner: current_user,
        trackable: project,
        parameters: {
          incharge_email: project.incharge_email,
          project_name: project.name
        }
      }
    end
  end
end