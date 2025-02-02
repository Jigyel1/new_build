# frozen_string_literal: true

module Projects
  class InchargeUnassigner < BaseService
    set_callback :call, :before, :notify_incharge

    def call
      authorize! project, to: :unassign_incharge?

      super { with_tracking { project.update!(incharge_id: nil) } }
    end

    def project
      @_project ||= Project.find(attributes[:id])
    end

    private

    def activity_params
      {
        action: :incharge_unassigned,
        owner: current_user,
        trackable: project,
        parameters: { project_name: project.name }
      }
    end

    def notify_incharge
      ProjectMailer.notify_unassigned(
        :incharge,
        project.incharge_id,
        project.id,
        current_user.id
      ).deliver_later
    end
  end
end
