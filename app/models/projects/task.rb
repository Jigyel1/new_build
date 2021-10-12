# frozen_string_literal: true

module Projects
  class Task < ApplicationRecord
    include Taskable

    # taskable can be a building or a project.
    belongs_to :taskable, polymorphic: true

    belongs_to :owner, class_name: 'Telco::Uam::User'
    belongs_to :assignee, class_name: 'Telco::Uam::User'

    validates :title, :description, :status, :due_date, presence: true

    default_scope { order(updated_at: :desc) }

    enum status: {
      todo: 'To-Do',
      in_progress: 'In Progress',
      completed: 'Completed',
      archived: 'Archived'
    }

    after_save :update_counter_caches

    private

    def update_counter_caches
      taskable.update_columns(
        completed_tasks_count: taskable.tasks.completed.count,
        tasks_count: taskable.tasks.where.not(status: :archived).count
      )
    end
  end
end
