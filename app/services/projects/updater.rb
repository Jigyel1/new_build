# frozen_string_literal: true

module Projects
  class Updater < BaseService
    set_callback :call, :after, :notify_assignee

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
      previous_assignee_id, assignee_id = project.saved_change_to_assignee_id

      if previous_assignee_id
        ProjectMailer.notify_unassigned(
          :assignee,
          previous_assignee_id,
          current_user.id,
          project.id
        ).deliver_later
      end

      return if assignee_id.nil? || assignee_id == current_user.id

      ProjectMailer.notify_assigned(:assignee, assignee_id, project.id, current_user.id).deliver_later if assignee_id
    end
  end
end
