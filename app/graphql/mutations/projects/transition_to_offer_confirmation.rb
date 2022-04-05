# frozen_string_literal: true

module Mutations
  module Projects
    class TransitionToOfferConfirmation < BaseMutation
      class TransitionToOfferConfirmationAttributes < Types::BaseInputObject
        argument :id, ID, required: true
      end

      argument :attributes, TransitionToOfferConfirmationAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(
          ::Projects::StatusUpdater,
          :project,
          attributes: attributes.to_h,
          event: :offer_confirmation
        )
      end
    end
  end
end
