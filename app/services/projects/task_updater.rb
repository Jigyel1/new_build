# frozen_string_literal: true

module Projects
  class TaskUpdater < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        task.update!(attributes)

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :task_updated,
        owner: current_user,
        recipient: task.assignee,
        trackable: task,
        parameters: {
          previous_status: task.previous_status,
          type: task.taskable_type.demodulize,
          status: task.status,
          title: task.title
        }
      }
    end
  end
end
