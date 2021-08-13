# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class CompetitionsResolver < SearchObjectBase
      scope { ::AdminToolkit::Competition.all }

      type Types::AdminToolkit::CompetitionConnectionType, null: false

      option :query, type: String, with: :apply_search

      def apply_search(scope, value)
        scope.where(
          "CONCAT_WS(' ', name, factor, lease_rate, description)
          iLIKE ?", "%#{value.squish}%"
        )
      end
    end
  end
end
