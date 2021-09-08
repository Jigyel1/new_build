# frozen_string_literal: true

module Mutations
  class UpdateProjectStatus < BaseMutation
    class UpdateProjectStatusAttributes < Types::BaseInputObject
      argument :id, ID, required: true
      argument :status, String, required: true
    end

    argument :attributes, UpdateProjectStatusAttributes, required: true
    field :project, Types::ProjectType, null: true

    def resolve(attributes:)
      super(::Projects::StatusUpdater, :project, attributes: attributes)
    end
  end
end
