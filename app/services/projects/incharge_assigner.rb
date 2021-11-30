# frozen_string_literal: true

module Projects
  class InchargeAssigner < BaseService
    set_callback :call, :after, :notify_incharge

    def call
      super do
        authorize! project, to: :update?

        with_tracking { project.update!(incharge_id: attributes[:incharge_id]) }
      end
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

    def notify_incharge
      ProjectMailer.notify_on_incharge_assigned(project.incharge_id, project.id).deliver_later
    end
  end
end
