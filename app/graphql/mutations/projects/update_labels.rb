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
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        resolver = ::Projects::LabelsUpdater.new(current_user: current_user, attributes: attributes.to_h)
        resolver.call
        { project: resolver.project }
      end
    end
  end
end
