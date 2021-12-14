# frozen_string_literal: true

module Projects
  class Updater < BaseService
    set_callback :call, :after, :notify_assignee
    set_callback :call, :after, :notify_unassigned_assignee

    def call
      authorize! project, to: :update?

      super { with_tracking { project.update!(attributes) } }
    end

    def project
      @project ||= ::Project.find(attributes.delete(:id))
    end

    private

    def activity_params
      {
        action: :project_updated,
        owner: current_user,
        trackable: project,
        parameters: { status: Project.statuses[project.status], project_name: project.name }
      }
    end

    def notify_assignee
      ProjectMailer.notify_on_assigned(project.assignee_id, project.id).deliver_later
    end

    def notify_unassigned_assignee
      return unless assignee_changed?

      ProjectMailer
        .notify_on_unassigned(project.assignee_id_previously_was, current_user.id, project.id).deliver_later
    end

    def assignee_changed?
      project.assignee_id_previously_changed? && project.assignee_id_previously_was.present?
    end
  end
end
