module Projects
  module Transitions
    class TechnicalAnalysisCompletionGuard < BaseService
      attr_accessor :project, :project_connection_cost

      def call
        run_validations
        calculate_pct
      end

      private

      def run_validations
        Transitions::TechnicalAnalysisCompletionValidator.new(project: project).call
      end

      def calculate_pct
        pct_calculator = ::Projects::PctCostCalculator.new(
          project_id: project.id,
          competition_id: project.competition_id,
          project_connection_cost: project_connection_cost
        )
        pct_calculator.call
        project.pct_cost = pct_calculator.pct_cost
      rescue RuntimeError => e
        raise(t('projects.transition.error_in_pct_calculation', error: e.message))
      end
    end
  end
end
