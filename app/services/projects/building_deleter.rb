# frozen_string_literal: true

module Projects
  class BuildingDeleter < BaseService
    include BuildingHelper

    def call
      authorize! building.project, to: :update?, with: ProjectPolicy
      building.destroy!
    end
  end
end
