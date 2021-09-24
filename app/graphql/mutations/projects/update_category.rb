# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateCategory < BaseMutation
      class UpdateCategoryAttributes < Types::BaseInputObject
        argument :project_id, ID, required: true
        argument :category, String, required: true
      end

      argument :attributes, UpdateCategoryAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(::Projects::CategoryUpdater, :project, attributes: attributes)
      end
    end
  end
end
