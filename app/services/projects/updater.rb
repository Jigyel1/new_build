# frozen_string_literal: true

module Projects
  class Updater < BaseService
    set_callback :call, :after, :notify_assignee

    def call
      authorize! project, to: :update?

      super do
        with_tracking do
          update_assignee
          project.update!(attributes)
        end
      end
    end

    def project
      @project ||= ::Project.find(attributes.delete(:id))
    end

    private

    def update_assignee
      project.update!(assignee_id: nil) if attributes[:assignee_id].blank? && project.assignee.present?
      project.update!(kam_assignee_id: nil) if attributes[:kam_assignee_id].blank? && project.kam_assignee.present?
    end

    def activity_params
      {
        action: :project_updated,
        owner: current_user,
        trackable: project,
        parameters: { status: Project.statuses[project.status], project_name: project.name }
      }
    end

    def notify_assignee
      previous_assignee_id, assignee_id = project.saved_change_to_assignee_id

      if previous_assignee_id.present? && previous_assignee_id != current_user.id
        notify_unassigned(previous_assignee_id)
      end

      notify_assigned(assignee_id) if assignee_id.present? && assignee_id != current_user.id
    end

    def notify_assigned(assignee_id)
      ProjectMailer.notify_assigned(:assignee, assignee_id, project.id, current_user.id).deliver_later
    end

    def notify_unassigned(assignee_id)
      ProjectMailer.notify_unassigned(:assignee, assignee_id, current_user.id, project.id).deliver_later
    end
  end
end
