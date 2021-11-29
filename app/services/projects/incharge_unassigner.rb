# frozen_string_literal: true

module Projects
  class InchargeUnassigner < BaseService
    set_callback :call, :after, :notify_unassigned_incharge

    def call
      authorize! project, to: :unassign_incharge?

      super do
        with_tracking { project.update!(incharge_id: nil) }
      end
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

    def notify_unassigned_incharge
      ProjectMailer.notify_on_incharge_unassigned(incharge_id, current_user.id, project.id).deliver_later
    end

    def incharge_id
      @_incharge_id ||= project.previous_changes.dig('incharge_id', 0)
    end
  end
end
