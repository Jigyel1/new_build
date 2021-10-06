# frozen_string_literal: true

module Mutations
  module Projects
    class UnarchiveProject < BaseMutation
      argument :id, ID, required: true
      field :project, Types::ProjectType, null: true

      def resolve(id:)
        super(
          ::Projects::StatusUpdater,
          :project,
          attributes: { id: id },
          event: :unarchive
        )
      end
    end
  end
end
