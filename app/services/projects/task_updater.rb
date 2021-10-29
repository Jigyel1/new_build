# frozen_string_literal: true

module Projects
  class TaskUpdater < BaseService
    include TaskHelper
    delegate :taskable, to: :task
    attr_reader :due_date_changed

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid) do
        task.assign_attributes(attributes)
        @due_date_changed = task.due_date_changed?
        task.save!
        delete_enqueued_jobs if @due_date_changed

        Activities::ActivityCreator.new(activity_params(activity_id)).call
      end
    end

    private

    def delete_enqueued_jobs
      return unless on_due_date_job_scheduled.present? && before_due_date_job_scheduled.present?

      before_due_date_job_scheduled.delete
      on_due_date_job_scheduled.delete
      task.job_ids.clear
      create_job
    end

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
