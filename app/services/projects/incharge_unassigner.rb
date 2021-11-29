# frozen_string_literal: true

module Projects
  class InchargeUnassigner < BaseService
    def call
      authorize! project, to: :unassign_incharge?

      with_tracking do
        project.update!(incharge_id: nil)
        ProjectMailer.notify_on_incharge_unassigned(incharge, current_user.id, project.id).deliver_later
      end
    end

    def project
      @project ||= Project.find(attributes[:id])
    end

    def incharge
      @incharge ||= project.previous_changes.dig('incharge_id', 0)
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
  end
end
