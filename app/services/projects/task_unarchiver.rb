# frozen_string_literal: true

module Projects
  class TaskUnarchiver < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    set_callback :call, :before, :validate_status!

    def call
      authorize! project, to: :update?
      super { task.update!(status: task.previous_status) }
    end

    private

    def validate_status!
      task.archived? || (raise t('projects.task.not_archived'))
    end
  end
end
