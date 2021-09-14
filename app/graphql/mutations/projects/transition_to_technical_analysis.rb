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
        resolver = ::Projects::StatusUpdater.new(
          current_user: current_user,
          attributes: attributes.to_h,
          event: :technical_analysis
        )

        resolver.call
        { project: resolver.project }
      end
    end
  end
end
