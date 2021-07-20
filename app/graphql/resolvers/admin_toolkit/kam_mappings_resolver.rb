# frozen_string_literal: true

module Resolvers
  module AdminToolkit
    class KamMappingsResolver < SearchObjectBase
      scope { ::AdminToolkit::KamMapping.all }

      type Types::AdminToolkit::KamMappingConnectionType, null: false

      option :kam_ids, type: [String], with: :apply_kam_ids_filter
      option :query, type: String, with: :apply_search
      option :skip, type: Int, with: :apply_skip

      def apply_kam_ids_filter(scope, value)
        scope.where(kam_id: value)
      end

      def apply_search(scope, value)
        scope.joins(kam: :profile).where(
          "CONCAT_WS(' ', investor_id, investor_description, firstname, lastname) iLIKE ?",
          "%#{value.strip}%"
        )
      end
    end
  end
end
