# frozen_string_literal: true

module Projects
  class InchargeAssigner < BaseService
    set_callback :call, :after, :notify_incharge

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
      previous_incharge_id, incharge_id = project.saved_change_to_incharge_id

      if previous_incharge_id.present? && previous_incharge_id != current_user.id
        notify_unassigned(previous_incharge_id)
      end

      notify_assigned(incharge_id) if incharge_id.present? && incharge_id != current_user.id
    end

    def notify_assigned(incharge_id)
      ProjectMailer.notify_assigned(:incharge, incharge_id, project.id, current_user.id).deliver_later
    end

    def notify_unassigned(incharge_id)
      ProjectMailer.notify_unassigned(:incharge, incharge_id, current_user.id, project.id).deliver_later
    end
  end
end
