# frozen_string_literal: true

module Projects
  class InchargeAssigner < BaseService
    set_callback :call, :after, :notify_incharge
    set_callback :call, :after, :notify_incharge_unassigned

    def call
      authorize! project, to: :update?

      super { with_tracking { project.update!(incharge_id: attributes[:incharge_id]) } }
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

    def notify_incharge_unassigned
      return if project.incharge_id_previously_changed?

      ProjectMailer.notify_on_incharge_unassigned(project.incharge.id, project.id, current_user.id).deliver
    end
  end
end
