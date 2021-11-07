# frozen_string_literal: true

module Projects
  class TaskDeleter < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :update?

      with_tracking { task.destroy! }
    end

    def activity_params
      {
        action: :task_deleted,
        owner: current_user,
        recipient: task.assignee,
        trackable: task,
        parameters: { type: task.taskable_type.demodulize, title: task.title }
      }
    end
  end
end
