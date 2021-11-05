# frozen_string_literal: true

module Projects
  class InchargeAssigner < BaseService
    def call
      authorize! project, to: :update?

      with_tracking { project.update!(incharge_id: attributes[:incharge_id]) }
    end

    def project
      @_project ||= Project.find(attributes[:project_id])
    end

    private

    def activity_params
      {
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
