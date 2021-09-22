# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateLabels < BaseMutation
      graphql_name 'ProjectsUpdateLabels'

      class UpdateProjectLabelsAttributes < Types::BaseInputObject
        argument :id, ID, required: true, description: "ID of the label group of the project. Not the project's ID"
        argument :labelList, String, required: true
      end

      argument :attributes, UpdateProjectLabelsAttributes, required: true
      field :label_group, Types::Projects::LabelGroupType, null: true

      def resolve(attributes:)
        super(::Projects::LabelsUpdater, :label_group, attributes: attributes)
      end
    end
  end
end
