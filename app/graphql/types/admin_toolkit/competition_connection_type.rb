# frozen_string_literal: true

module Types
  module AdminToolkit
    class CompetitionConnectionType < GraphQL::Types::Relay::BaseConnection
      edge_type(Types::AdminToolkit::CompetitionEdgeType)

      field :total_count, Integer, null: false

      # - `object` is the Connection
      # - `object.items` is the original collection of Competitions
      def total_count
        object.items.size
      end
    end
  end
end
