# frozen_string_literal: true

module Projects
  class TaskUpdater < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :update?, with: ProjectPolicy

      with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
        task.update!(attributes)

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :task_updated,
        owner: current_user,
        recipient: task.assignee,
        trackable: task,
        parameters: attributes
      }
    end
  end
end
