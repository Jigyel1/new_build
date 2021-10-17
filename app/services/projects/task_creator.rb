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

          Activities::ActivityCreator.new(activity_params(activity_id)).call
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

    def activity_params(activity_id)
      {
        activity_id: activity_id,
        action: :task_created,
        owner: current_user,
        recipient: task.assignee,
        trackable: taskable,
        parameters: { copy: display_text, title: attributes['title'] }
      }
    end

    def display_text
      'and copied to all the buildings' if @copy_to_all_buildings
    end
  end
end
