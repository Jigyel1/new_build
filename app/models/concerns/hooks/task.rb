# frozen_string_literal: true

module Hooks
  module Task
    extend ActiveSupport::Concern

    included do
      after_save :update_counter_caches
      after_create :save_project_id, :save_building_id, :save_project_name
    end

    def save_building_id
      self.building_id = taskable_id if building?
    end

    def save_project_id
      self.project_id = if building?
                          ::Projects::Building.find(taskable_id).project.id
                        else
                          taskable_id
                        end
    end

    def save_project_name
      self.project_name = if building?
                            ::Projects::Building.find(taskable_id).project.name
                          else
                            ::Project.find(taskable_id).name
                          end
    end

    private

    def building?
      taskable_type == 'Projects::Building'
    end

    def update_counter_caches
      taskable.update_columns(
        completed_tasks_count: taskable.tasks.completed.count,
        tasks_count: taskable.tasks.where.not(status: :archived).count
      )
    end
  end
end
