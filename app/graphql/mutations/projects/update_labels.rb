# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateLabels < BaseMutation
      graphql_name 'ProjectsUpdateLabels' # To avoid name conflict with `AdminToolkit::UpdateLabels`

      class UpdateProjectLabelsAttributes < Types::BaseInputObject
        argument :id, ID, required: true, description: "ID of the label group of the project. Not the project's ID"
        argument :label_list, String, required: true
      end

      argument :attributes, UpdateProjectLabelsAttributes, required: true
      field :label_group, Types::Projects::LabelGroupType, null: true

      def resolve(attributes:)
        super(::Projects::LabelsUpdater, :label_group, attributes: attributes)
      end
    end
  end
end
