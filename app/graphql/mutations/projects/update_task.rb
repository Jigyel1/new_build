# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateTask < BaseMutation
      class UpdateTaskAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :title, String, required: false
        argument :description, String, required: false
        argument :status, String, required: false
        argument :due_date, String, required: false
        argument :assignee_id, ID, required: false
      end

      argument :attributes, UpdateTaskAttributes, required: true
      field :task, Types::Projects::TaskType, null: true

      def resolve(attributes:)
        super(::Projects::TaskUpdater, :task, attributes: attributes.to_h)
      end
    end
  end
end
