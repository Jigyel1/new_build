# frozen_string_literal: true

module Hooks
  module Task
    extend ActiveSupport::Concern

    included do
      after_save :update_counter_caches
      before_create :assign_project_building_name, :assign_ids, :assign_host_url
      after_destroy :update_counter_caches
    end

    def assign_project_building_name
      self.project_name = building? ? project_building.name : project.name
      self.building_name = project_building.name if building?
    end

    def assign_ids
      self.building_id = taskable_id if building?
      self.project_id = building? ? project_building.id : taskable_id
    end

    def assign_host_url
      self.host_url = Rails.application.config.host_url
    end

    private

    def project
      ::Project.find(taskable_id)
    end

    def project_building
      ::Projects::Building.find(taskable_id).project
    end

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
