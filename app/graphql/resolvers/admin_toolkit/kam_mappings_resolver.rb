# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class KamMappingsResolver < SearchObjectBase
      scope { ::AdminToolkit::KamMapping.all }

      type Types::AdminToolkit::KamMappingConnectionType, null: false

      option :query, type: String, with: :apply_search
      option :skip, type: Int, with: :apply_skip

      # filter by kam id

      def apply_search(scope, value)
        # joins by kam
        # use concat to join firstname & lastname
        scope.joins(kam: :profile).where(
          "CONCAT_WS(' ', investor_id investor_description profiles.firstname)
          iLIKE ?", "%#{value.strip}%"
        )
      end
    end
  end
end
