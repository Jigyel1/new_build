# frozen_string_literal: true

module Types
  class ProjectConnectionType < BaseConnectionType
    edge_type(Types::ProjectEdgeType)

    field :count_by_statuses, GraphQL::Types::JSON, null: true

    def count_by_statuses
      ProjectsList.select(:status).group(:status).count
    end
  end
end
