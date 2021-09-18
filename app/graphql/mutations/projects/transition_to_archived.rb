# frozen_string_literal: true

module Mutations
  module Projects
    class TransitionToArchived < BaseMutation
      class TransitionToArchivedAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :verdict, String, required: false
      end

      argument :attributes, TransitionToArchivedAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        resolver = ::Projects::StatusUpdater.new(
          current_user: current_user,
          attributes: attributes.to_h,
          event: :archive
        )

        resolver.call
        { project: resolver.project }
      end
    end
  end
end
