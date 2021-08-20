# frozen_string_literal: true

module Projects
  class TaskDeleter < BaseService
    include TaskHelper
    delegate :taskable, to: :task

    def call
      authorize! project, to: :update?, with: ProjectPolicy
      task.destroy!
    end
  end
end
