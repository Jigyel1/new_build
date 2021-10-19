# frozen_string_literal: true

module Projects
  class TaskDeleter < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        task.destroy!
        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :task_deleted,
        owner: current_user,
        recipient: task.assignee,
        trackable: task,
        parameters: { type: task.taskable_type.demodulize, title: task.title }
      }
    end
  end
end
