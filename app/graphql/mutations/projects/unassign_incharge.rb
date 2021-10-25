# frozen_string_literal: true

module Mutations
  module Projects
    class UnassignIncharge < BaseMutation
      argument :id, ID, required: true
      field :project, Types::ProjectType, null: true

      def resolve(id:)
        super(::Projects::InchargeUnassigner, :project, attributes: { id: id })
      end
    end
  end
end
