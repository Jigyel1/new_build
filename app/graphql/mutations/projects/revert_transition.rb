# frozen_string_literal: true

module Mutations
  module Projects
    class RevertTransition < BaseMutation
      class RevertTransitionAttributes < Types::BaseInputObject
        argument :id, ID, required: true
      end

      argument :attributes, RevertTransitionAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        resolver = ::Projects::StatusUpdater.new(
          current_user: current_user,
          attributes: attributes.to_h,
          event: :revert
        )

        resolver.call
        { project: resolver.project }
      end
    end
  end
end
