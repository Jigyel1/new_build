# frozen_string_literal: true

module Mutations
  module Projects
    class TransitionToTechnicalAnalysis < BaseMutation
      class TransitionToTechnicalAnalysisAttributes < Types::BaseInputObject
        argument :id, ID, required: true
      end

      argument :attributes, TransitionToTechnicalAnalysisAttributes, required: true
      field :project, Types::ProjectType, null: true

      def resolve(attributes:)
        super(
          ::Projects::StatusUpdater,
          :project,
          attributes: attributes.to_h,
          event: :technical_analysis
        )
      end
    end
  end
end
