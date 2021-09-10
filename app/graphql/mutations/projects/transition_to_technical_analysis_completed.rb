# frozen_string_literal: true

module Mutations
  module Projects
    class TransitionToTechnicalAnalysisCompleted < BaseMutation
      class TransitionToTechnicalAnalysisCompletedAttributes < Types::BaseInputObject
        argument :id, ID, required: true
      end

      argument :attributes, TransitionToTechnicalAnalysisCompletedAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(
          ::Projects::StatusUpdater,
          :project,
          attributes: attributes.to_h.merge(event: :technical_analysis_completed)
        )
      end
    end
  end
end
