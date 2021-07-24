# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class PenetrationsResolver < SearchObjectBase
      scope { ::AdminToolkit::Penetration.all }

      type Types::AdminToolkit::PenetrationConnectionType, null: false

      option(:competitions, type: [String]) { |scope, value| scope.where(competition: value) }
      option(:kam_regions, type: [String]) { |scope, value| scope.where(kam_region: value) }
      option(:hfc_footprint, type: [Boolean]) { |scope, value| scope.where(hfc_footprint: value) }
      option(:types, type: [String]) { |scope, value| scope.where(type: value) }

      option :query, type: String, with: :apply_search
      option :skip, type: Int, with: :apply_skip

      def apply_search(scope, value)
        scope.where(
          "CONCAT_WS(' ', zip, city, rate, competition, type, hfc_footprint, kam_region)
          iLIKE ?", "%#{value.squish}%"
        )
      end
    end
  end
end
