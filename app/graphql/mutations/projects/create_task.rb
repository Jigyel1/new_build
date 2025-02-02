# frozen_string_literal: true

module Mutations
  module Projects
    class CreateTask < BaseMutation
      class CreateTaskAttributes < Types::BaseInputObject
        argument :taskable_id, ID, required: true
        argument :taskable_type, String, required: true, description: <<~DESC
          If project, send "Project". If building, send the value as "Projects::Building"
        DESC

        argument :title, String, required: true
        argument :description, String, required: true
        argument :status, String, required: true
        argument :due_date, String, required: true
        argument :assignee_id, ID, required: true

        argument :copy_to_all_buildings, Boolean, required: false, description: <<~DESC
          When true, this task will be cloned for all the buildings belonging to the project.
        DESC
      end

      argument :attributes, CreateTaskAttributes, required: true
      field :task, Types::Projects::TaskType, null: true

      def resolve(attributes:)
        super(::Projects::TaskCreator, :task, attributes: attributes.to_h)
      end
    end
  end
end
