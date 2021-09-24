module Projects
  module Transitions
    module Guards
      private

      def authorized?
        authorize! project, to: "to_#{aasm.to_state}?", with: ProjectPolicy
      end

      def to_technical_analysis_completed?
        # Project does not accept nested attribute for PCT Cost. So extract and remove
        # the necessary attributes before assigning those to the project.
        pct_cost = OpenStruct.new(attributes.delete(:pct_cost_attributes))

        verdict = attributes.delete(:verdict)
        project.verdicts[aasm.to_state] = verdict if verdict.present?

        project.assign_attributes(attributes)

        Transitions::TechnicalAnalysisCompletionGuard.new(
          project: project,
          project_connection_cost: pct_cost.project_connection_cost
        ).call

        true
      end

      def to_archived?
        verdict = attributes.delete(:verdict)
        project.verdicts[aasm.to_state] = verdict if verdict.present?

        true
      end

      def to_offer?
        verdict = attributes.delete(:verdict)
        project.verdicts[aasm.to_state] = verdict if verdict.present?

        true
      end
    end
  end
end
