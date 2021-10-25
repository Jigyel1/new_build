# frozen_string_literal: true

module Mutations
  module Projects
    class AssignIncharge < BaseMutation
      class AssignInchargeAttributes < Types::BaseInputObject
        argument :project_id, ID, required: true
        argument :incharge_id, ID, required: true
      end

      argument :attributes, AssignInchargeAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(::Projects::InchargeAssigner, :project, attributes: attributes)
      end
    end
  end
end
