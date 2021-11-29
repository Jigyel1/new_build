# frozen_string_literal: true

module Resolvers
  class ProjectsResolver < SearchObjectBase
    scope { ProjectsList.order('move_in_starts_on ASC NULLS LAST') }

    type Types::ProjectConnectionType, null: false

    option(:statuses, type: [String]) { |scope, value| scope.where(status: value) }
    option(:categories, type: [String]) { |scope, value| scope.where(category: value) }
    option(:assignees, type: [String]) { |scope, value| scope.where(assignee_id: value) }
    option(:priorities, type: [String]) { |scope, value| scope.where(priority: value) }
    option(:construction_types, type: [String]) { |scope, value| scope.where(construction_type: value) }
    option(:internal_ids, type: [String]) { |scope, value| scope.where(internal_id: value) }
    option(:customer_requests, type: [Boolean]) { |scope, value| scope.where(customer_request: value) }
    option(:lot_numbers, type: [String]) { |scope, value| scope.where(lot_number: value) }
    option(:kam_regions, type: [String]) { |scope, value| scope.where(kam_region: value) }

    option :buildings_count, type: [Int], with: :apply_buildings_filter, description: <<~DESC
      Send min and max values in the array. eg. [2, 10]. Only the first two values will be picked.
    DESC

    option :apartments_count, type: [Int], with: :apply_apartments_filter, description: <<~DESC
      Send min and max values in the array. eg. [2, 10]. Only the first two values will be picked.
    DESC

    option :query, type: String, with: :apply_search, description: <<~DESC
      Supports searches on project's name, external_id, project_nr, type,
      construction_type, lot_number, address, assignee, investor, kam_region
    DESC

    def apply_buildings_filter(scope, value)
      apply_range_filter(scope, :buildings_count, value)
    end

    def apply_apartments_filter(scope, value)
      apply_range_filter(scope, :apartments_count, value)
    end

    def apply_search(scope, value)
      scope.where(
        "CONCAT_WS(' ', name, external_id, project_nr, priority, construction_type,
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
