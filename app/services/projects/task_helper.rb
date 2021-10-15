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
  end
end
