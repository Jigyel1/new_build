# frozen_string_literal: true

module Mutations
  class ExportActivities < BaseMutation
    argument :attributes, Types::ActivityQueryType, required: true
    field :url, String, null: true

    def resolve(attributes:)
      resolver = Activities::ActivityExporter.new(current_user: current_user, attributes: attributes)

      { url: resolver.call }
    end
  end
end
