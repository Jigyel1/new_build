# frozen_string_literal: true

module Projects
  class TaskCreator < BaseService
    include TaskHelper
    attr_reader :task

    def call
      authorize! project, to: :create?, with: ProjectPolicy
      @task = current_user.tasks.create!(attributes)
    end
  end
end