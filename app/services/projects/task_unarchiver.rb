# frozen_string_literal: true

module Projects
  class TaskUnarchiver < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :update?, with: ProjectPolicy
      validate_status!
      task.update!(status: task.previous_status)
    end

    private

    def validate_status!
      task.archived? || (raise t('project.task_not_archived'))
    end
  end
end
