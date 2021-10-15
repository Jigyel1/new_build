# frozen_string_literal: true

module Resolvers
  module Projects
    class TaskResolver < BaseResolver
      argument :id, ID, required: true
      type Types::Projects::TaskType, null: true

      def resolve(id:)
        ::Projects::Task.find(id)
      end
    end
  end
end
