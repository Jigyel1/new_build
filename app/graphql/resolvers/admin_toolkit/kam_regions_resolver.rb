# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class KamRegionsResolver < SearchObjectBase
      scope { ::AdminToolkit::KamRegion.all }

      type Types::AdminToolkit::KamRegionConnectionType, null: false

      option(:kam_ids, type: [String]) { |scope, value| scope.where(kam_id: value) }
      option :query, type: String, with: :apply_search

      def apply_search(scope, value)
        scope.joins(kam: :profile).where(
          "CONCAT_WS(' ', name, firstname, lastname, email) iLIKE ?",
          "%#{value.squish}%"
        )
      end
    end
  end
end
