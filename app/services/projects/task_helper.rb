# frozen_string_literal: true

module Projects
  module TaskHelper
    def task
      @task ||= Projects::Task.find(attributes[:id])
    end

    private

    def taskable
      @taskable ||= taskable_class.find(attributes[:taskable_id])
    end

    # Can be a project or a building
    def taskable_class
      attributes[:taskable_type].constantize
    end

    # `Taskable` can either be a `project` or a `building`.
    # If its a `project`, return that. Else, it will be a building in which case,
    # you return `taskable.project`
    def project
      @project ||= taskable.is_a?(Project) ? taskable : taskable.project
    end

    def create_job
      before_due_date = TaskReminderBeforeDueDateJob.set(wait: 1.hour).perform_later(task.assignee.id)
      on_due_date = TaskReminderOnDueDateJob.set(wait: 1.hour).perform_later(task.assignee.id)
      task.job_ids = [before_due_date.job_id, on_due_date.job_id]
      task.save!
    end

    def on_due_date_job_scheduled
      binding.pry
      queue_a = Sidekiq::Queue.new('on_due_date')
      queue_a.each do |job|
        return job if job.args.pluck('job_id').present?
      end
    end

    def before_due_date_job_scheduled
      queue_b = Sidekiq::Scheduled.new('before_due_date')
      queue_b.each do |job|
        return job if job.args.pluck('job_id').present?
      end
    end
  end
end
