# frozen_string_literal: true

module Mutations
  module Projects
    class UnarchiveTask < BaseMutation
      argument :id, ID, required: true
      field :task, Types::Projects::TaskType, null: true

      def resolve(id:)
        super(::Projects::TaskUnarchiver, :task, attributes: { id: id })
      end
    end
  end
end
