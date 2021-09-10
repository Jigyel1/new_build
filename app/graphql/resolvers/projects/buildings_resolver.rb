# frozen_string_literal: true

module Resolvers
  module Projects
    class BuildingsResolver < SearchObjectBase
      scope do
        ::Projects::Building
      end

      type Types::Projects::BuildingConnectionType, null: false

      option(:project_id, type: String, required: true) { |scope, value| scope.where(project_id: value) }

      option :query, type: String, with: :apply_search, description: <<~DESC
        Supports searches on building's name, external_id, address, move in date, assignee's name
      DESC

      def apply_search(scope, value)
        scope.left_joins(:address, assignee: :profile).where(
          "CONCAT_WS(
            ' ', name, external_id, move_in_starts_on, profiles.firstname, profiles.lastname,
            addresses.street, addresses.street_no, addresses.city, addresses.zip
          ) iLIKE ?",
          "%#{value.squish}%"
        )
      end
    end
  end
end
