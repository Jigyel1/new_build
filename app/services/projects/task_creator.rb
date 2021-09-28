# frozen_string_literal: true

module Projects
  class TaskCreator < BaseService
    include TaskHelper
    attr_reader :task

    set_callback :call, :before, :extract_param!

    def call
      authorize! project, to: :update?

      with_tracking(activity_id = SecureRandom.uuid, transaction: true) do
        super do
          @task = current_user.tasks.create!(attributes)
          copy_task_to_all_buildings if @copy_to_all_buildings
        end
      end
    end

    private

    def copy_task_to_all_buildings
      target_buildings.each do |building|
        building.tasks.create!(
          task.attributes.symbolize_keys.except(:id, :taskable_id, :taskable_type)
        )
      end
    end

    # project buildings except the current task's building if `taskable_type` is a building as that
    # task will already be created.
    def target_buildings
      return project.buildings if taskable.is_a?(Project)

      project.buildings.where.not(id: taskable)
    end

    def extract_param!
      @copy_to_all_buildings = attributes.delete(:copy_to_all_buildings)
    end
  end
end
