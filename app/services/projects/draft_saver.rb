# frozen_string_literal: true

module Projects
  class DraftSaver < BaseService
    def call
      authorize! project, to: :update?
      project.update!(draft_version: attributes[:draft_version])
    end

    def project
      @_project ||= Project.find(attributes.delete(:id))
    end
  end
end
