# frozen_string_literal: true

module Mutations
  module Projects
    class TransitionToReadyForOffer < BaseMutation
      class TransitionToReadyForOfferAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :verdict, String, required: false
      end

      argument :attributes, TransitionToReadyForOfferAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        resolver = ::Projects::StatusUpdater.new(
          current_user: current_user,
          attributes: attributes.to_h,
          event: :offer_ready
        )

        resolver.call
        { project: resolver.project }
      end
    end
  end
end
