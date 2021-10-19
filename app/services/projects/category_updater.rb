# frozen_string_literal: true

module Projects
  class CategoryUpdater < BaseService
    def call
      authorize! project, to: :update?

      project.update!(
        category: attributes[:category],
        system_sorted_category: false
      )
    end

    def project
      @_project ||= Project.find(attributes[:project_id])
    end
  end
end
