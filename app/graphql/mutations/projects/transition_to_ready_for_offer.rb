# frozen_string_literal: true

module Mutations
  module Projects
    class TransitionToReadyForOffer < BaseMutation
      class TransitionToReadyForOfferAttributes < Types::BaseInputObject
        argument :id, ID, required: true
        argument :verdicts, GraphQL::Types::JSON, required: false
      end

      argument :attributes, TransitionToReadyForOfferAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(
          ::Projects::StatusUpdater,
          :project,
          attributes: attributes.to_h,
          event: :offer_ready
        )
      end
    end
  end
end