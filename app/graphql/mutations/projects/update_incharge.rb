# frozen_string_literal: true

module Mutations
  module Projects
    class UpdateIncharge < BaseMutation
      class UpdateInchargeAttributes < Types::BaseInputObject
        argument :project_id, String, required: true
        argument :incharge_id, String, required: true
      end

      argument :attributes, UpdateInchargeAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(::Projects::InchargeUpdater, :project, attributes: attributes)
      end
    end
  end
end
