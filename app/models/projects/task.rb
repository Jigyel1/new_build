# frozen_string_literal: true

module Projects
  class Task < ApplicationRecord
    include Trackable

    # taskable can be a building or a project.
    belongs_to :taskable, polymorphic: true

    belongs_to :owner, class_name: 'Telco::Uam::User'
    belongs_to :assignee, class_name: 'Telco::Uam::User'

    validates :title, :description, :status, :due_date, presence: true

    default_scope { order(updated_at: :desc) }

    enum status: {
      todo: 'To-Do',
      in_progress: 'In progress',
      completed: 'Completed',
      archived: 'Archived'
    }

    after_save :update_counter_caches, :update_name_and_ids

    private

    def update_counter_caches
      taskable.update_columns(
        completed_tasks_count: taskable.tasks.completed.count,
        tasks_count: taskable.tasks.where.not(status: :archived).count
      )
    end

    def update_name_and_ids
      self.building_id = self.taskable_id if self.taskable_type == 'Projects::Building'
      self.project_id = if self.taskable_type == 'Projects::Building'
                          ::Projects::Building.find(self.taskable_id).project.id
                        else
                          self.taskable_id
                        end
      self.project_name = if self.taskable_type == 'Projects::Building'
                            ::Projects::Building.find(self.taskable_id).project.name
                          else
                            self.taskable_id
                          end
    end
  end
end
