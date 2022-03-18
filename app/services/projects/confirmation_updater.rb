# frozen_string_literal: true

module Projects
  class ConfirmationUpdater < BaseService
    def call
      authorize! project, to: :update?

      project.update!(confirmation_status: attributes[:confirmation_status])
    end

    def project
      @_project ||= Project.find(attributes[:project_id])
    end
  end
end
