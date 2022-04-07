# frozen_string_literal: true

module Hooks
  module Task
    extend ActiveSupport::Concern

    included do
      after_save :update_counter_caches
      before_create :assign_default_attributes
      after_destroy :update_counter_caches
    end

    def assign_default_attributes # rubocop:disable Metrics/AbcSize
      self.building_id = taskable_id if building?
      self.project_id = building? ? project.id : taskable_id
      self.project_name = building? ? project.name : ::Project.find(taskable_id).name
      self.building_name = project.name if building?
      self.host_url = Rails.application.config.host_url
    end

    private

    def project
      ::Projects::Building.find(taskable_id).project
    end

    def building?
      taskable_type.is_a?(Projects::Building)
    end

    def update_counter_caches
      taskable.update_columns(
        completed_tasks_count: taskable.tasks.completed.size,
        tasks_count: taskable.tasks.where.not(status: :archived).size
      )
    end
  end
end
