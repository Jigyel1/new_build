module Taskable
  extend ActiveSupport::Concern

  included do
    after_save :update_counter_caches
  end

  private

  def update_counter_caches
    update_columns(
      completed_tasks_count: tasks.completed.count,
      tasks_count: tasks.where.not(status: :archived).count
    )
  end
end
