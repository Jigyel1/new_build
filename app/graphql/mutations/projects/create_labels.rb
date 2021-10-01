# frozen_string_literal: true

module Mutations
  module Projects
    class CreateLabels < BaseMutation
      class CreateProjectLabelsAttributes < Types::BaseInputObject
        argument :project_id, ID, required: true
        argument :label_group_id, ID, required: true
        argument :labelList, String, required: true
      end

      argument :attributes, CreateProjectLabelsAttributes, required: true
      field :label_group, Types::Projects::LabelGroupType, null: true

      def resolve(attributes:)
        super(::Projects::LabelsCreator, :label_group, attributes: attributes)
      end
    end
  end
end
