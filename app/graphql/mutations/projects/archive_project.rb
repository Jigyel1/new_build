# frozen_string_literal: true

module Mutations
  module Projects
    class ArchiveProject < BaseMutation
      class ArchiveProjectAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :verdicts, GraphQL::Types::JSON, required: false
      end

      argument :attributes, ArchiveProjectAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(
          ::Projects::StatusUpdater,
          :project,
          attributes: attributes.to_h,
          event: :archive
        )
      end
    end
  end
end
