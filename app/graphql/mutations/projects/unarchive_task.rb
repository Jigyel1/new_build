# frozen_string_literal: true

module Mutations
  module Projects
    class UnarchiveTask < BaseMutation
      argument :id, ID, required: true
      field :task, Types::Projects::TaskType, null: true

      def resolve(id:)
        resolver = ::Projects::TaskUnarchiver.new(current_user: current_user, attributes: { id: id })
        resolver.call
        { task: resolver.task }
      end
    end
  end
end
