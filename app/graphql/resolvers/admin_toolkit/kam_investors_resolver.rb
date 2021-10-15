# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class KamInvestorsResolver < SearchObjectBase
      scope { ::AdminToolkit::KamInvestor.all }

      type Types::AdminToolkit::KamInvestorConnectionType, null: false

      option(:kam_ids, type: [String]) { |scope, value| scope.where(kam_id: value) }
      option :query, type: String, with: :apply_search

      def apply_search(scope, value)
        scope.joins(kam: :profile).where(
          "CONCAT_WS(' ', investor_id, investor_description, firstname, lastname, email) iLIKE ?",
          "%#{value.squish}%"
        )
      end
    end
  end
end
