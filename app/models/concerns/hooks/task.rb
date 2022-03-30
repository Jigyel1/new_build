# frozen_string_literal: true

module Hooks
  module Task
    extend ActiveSupport::Concern

    included do
      after_save :update_counter_caches
      before_create :assign_project_id, :assign_building_id, :assign_project_name,
                    :assign_host_url, :assign_building_name
    end

    def assign_building_id
      self.building_id = taskable_id if building?
    end

    def assign_project_id
      self.project_id = building? ? ::Projects::Building.find(taskable_id).project.id : taskable_id
    end

    def assign_project_name
      self.project_name = if building?
                            ::Projects::Building.find(taskable_id).project.name
                          else
                            ::Project.find(taskable_id).name
                          end
    end

    def assign_building_name
      self.building_name = ::Projects::Building.find(taskable_id).name if building?
    end

    def assign_host_url
      self.host_url = Rails.application.config.host_url
    end

    private

    def building?
      taskable_type == 'Projects::Building'
    end

    def update_counter_caches
      taskable.update_columns(
        completed_tasks_count: taskable.tasks.completed.size,
        tasks_count: taskable.tasks.where.not(status: :archived).size
      )
    end
  end
end
