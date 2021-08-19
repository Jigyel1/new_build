# frozen_string_literal: true

module Resolvers
  class ProjectsResolver < SearchObjectBase
    scope do
      ProjectsList.all
    end

    type Types::ProjectConnectionType, null: false

    option(:categories, type: [String]) { |scope, value| scope.where(category: value) }
    option(:assignees, type: [String]) { |scope, value| scope.where(assignee_id: value) }
    option(:types, type: [String]) { |scope, value| scope.where(type: value) }
    option(:construction_types, type: [String]) { |scope, value| scope.where(construction_type: value) }

    option :buildings, type: [Int], with: :apply_buildings_filter, description: <<~DESC
      Send min and max values in the array. eg. [2, 10]. Only the first two values will be picked.
    DESC

    option :apartments, type: [Int], with: :apply_apartments_filter, description: <<~DESC
      Send min and max values in the array. eg. [2, 10]. Only the first two values will be picked.
    DESC

    option :query, type: String, with: :apply_search, description: <<~DESC
      Supports searches on project's name, external_id, project_nr, type, 
      construction_type, lot_number, address, assignee, investor, kam_region
    DESC

    def apply_buildings_filter(scope, value)
      apply_range_filter(scope, :buildings, value)
    end

    def apply_apartments_filter(scope, value)
      apply_range_filter(scope, :apartments, value)
    end

    def apply_search(scope, value)
      scope.where(
        "CONCAT_WS(' ', name, external_id, project_nr, type, construction_type,
        lot_number, address, assignee, investor, kam_region) iLIKE ?",
        "%#{value.squish}%"
      )
    end

    private

    def apply_range_filter(scope, attribute, value)
      min, max = value.sort
      scope.where("#{attribute}": min..max)
    end
  end
end
