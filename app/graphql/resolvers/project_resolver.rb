# frozen_string_literal: true

module Resolvers
  class ProjectResolver < BaseResolver
    argument :id, ID, required: true
    type Types::ProjectType, null: true

    def resolve(id:)
      Project.find(id)
    end
  end
end
