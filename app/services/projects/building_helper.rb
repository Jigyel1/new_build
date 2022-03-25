# frozen_string_literal: true

module Projects
  module BuildingHelper
    def building
      @_building ||= Projects::Building.find(attributes.delete(:id))
    end

    def project
      @_project ||= building.project
    end
  end
end
