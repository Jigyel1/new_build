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
      task.job_ids = [before_due_date.job_id, on_due_date.job_id]
      task.save!
    end

    def before_due_date
      scheduled_time = ((task.due_date.to_time - 1.day) + 9.hours)
      TaskReminderBeforeDueDateJob.set(wait_until: scheduled_time).perform_later(task.assignee.id, task.id)
    end

    def on_due_date
      scheduled_time = task.due_date.to_time + 17.hours
      TaskReminderOnDueDateJob.set(wait_until: scheduled_time).perform_later(task.assignee.id, task.id)
    end

    def job_scheduled(queue_name)
      scheduler = Sidekiq::ScheduledSet.new
      jobs = scheduler.select { |selected| selected.queue == queue_name }
      jobs.each do |job|
        return job if task.job_ids.include?(job.args.dig(0, 'job_id'))
      end
    end
  end
end
