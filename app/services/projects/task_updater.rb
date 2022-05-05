# frozen_string_literal: true

module Projects
  class TaskUpdater < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :assignee?

      with_tracking do
        if attributes[:status] == task.status
          task.update!(attributes)
        else
          task.update!(status: attributes[:status])
        end
      end
    end

    def activity_params
      {
        action: :task_updated,
        owner: current_user,
        recipient: task.assignee,
        trackable: task,
        parameters: {
          previous_status: task.previous_status.try(:titleize),
          type: task.taskable_type.demodulize,
          status: task.status.titleize,
          title: task.title
        }
      }
    end
  end
end
