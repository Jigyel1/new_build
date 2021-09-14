module Projects
  module BuildingHelper
    def building
      @_building ||= Projects::Building.find(attributes.delete(:id))
    end
  end
end
