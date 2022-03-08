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

      if previous_incharge_id
        ProjectMailer.notify_unassigned(
          :incharge,
          previous_incharge_id,
          current_user.id,
          project.id
        ).deliver_later
      end

      return if incharge_id == current_user.id

      ProjectMailer.notify_assigned(:incharge, incharge_id, project.id, current_user.id).deliver_later if incharge_id
    end
  end
end
