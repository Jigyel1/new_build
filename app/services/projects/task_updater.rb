# frozen_string_literal: true

module Projects
  class TaskUpdater < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :update?

      with_tracking { task.update!(attributes) }
    end

    def activity_params
      {
        action: :task_updated,
        owner: current_user,
        recipient: task.assignee,
        trackable: task,
        parameters: {
          previous_status: task.previous_status.humanize,
          type: task.taskable_type.demodulize,
          status: task.status.titleize.humanize,
          title: task.title
        }
      }
    end
  end
end
