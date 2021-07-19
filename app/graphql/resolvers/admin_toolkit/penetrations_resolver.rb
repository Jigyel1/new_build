# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class PenetrationsResolver < SearchObjectBase
      scope { ::AdminToolkit::Penetration.all }

      type Types::AdminToolkit::PenetrationConnectionType, null: false

      option :competitions, type: [String], with: :apply_competitions_filter
      option :kam_regions, type: [String], with: :apply_kam_regions_filter
      option :hfc_footprint, type: [Boolean], with: :apply_hfc_footprints_filter
      option :types, type: [String], with: :apply_types_filter

      option :query, type: String, with: :apply_search
      option :skip, type: Int, with: :apply_skip

      def apply_competitions_filter(scope, value)
        scope.where(competition: value)
      end

      def apply_hfc_footprints_filter(scope, value)
        scope.where(hfc_footprint: value)
      end

      def apply_types_filter(scope, value)
        scope.where(type: value)
      end

      def apply_search(scope, value)
        scope.where(
          "CONCAT_WS(' ', zip, city, rate, competition, type, hfc_footprint, kam_region)
          iLIKE ?", "%#{value.strip}%"
        )
      end
    end
  end
end
