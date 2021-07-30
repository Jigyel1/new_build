# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class PenetrationsResolver < SearchObjectBase
      scope { ::AdminToolkit::Penetration.all }

      type Types::AdminToolkit::PenetrationConnectionType, null: false

      option(:hfc_footprint, type: [Boolean]) { |scope, value| scope.where(hfc_footprint: value) }
      option(:types, type: [String]) { |scope, value| scope.where(type: value) }

      option(:kam_regions, type: [String]) do |scope, value|
        scope.joins(:kam_region).where(admin_toolkit_kam_regions: { name: value })
      end

      option(:competitions, type: [String]) do |scope, value|
        scope.joins(:competition).where(admin_toolkit_competitions: { name: value })
      end

      option :query, type: String, with: :apply_search
      option :skip, type: Int, with: :apply_skip

      def apply_search(scope, value)
        scope.left_outer_joins(:competition, kam_region: { kam: :profile }).where(
          "CONCAT_WS(' ', zip, city, rate, type, hfc_footprint,
          admin_toolkit_competitions.name, admin_toolkit_competitions.description,
          admin_toolkit_kam_regions.name, firstname, lastname, email)
          iLIKE ?", "%#{value.squish}%"
        )
      end
    end
  end
end