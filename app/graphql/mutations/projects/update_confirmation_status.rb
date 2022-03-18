# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateConfirmationStatus < BaseMutation
      class UpdateConfirmationStatusAttributes < Types::BaseInputObject
        argument :project_id, ID, required: true
        argument :confirmation_status, String, required: true
      end

      argument :attributes, UpdateConfirmationStatusAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(::Projects::ConfirmationUpdater, :project, attributes: attributes)
      end
    end
  end
end
