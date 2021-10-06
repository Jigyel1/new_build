# frozen_string_literal: true

module Projects
  module Transitions
    module Helper
      private

      def update_project_state
        project.update!(status: aasm.to_state)
      end

      def reset_draft_version
        project.update_column(:draft_version, {})
      end

      def project_priority
        @_project_priority ||= begin
          months = project.pct_cost.payback_period
          cost = project.pct_cost.project_cost

          AdminToolkit::PctValue
            .joins(:pct_cost, :pct_month)
            .where('admin_toolkit_pct_months.min <= :value AND admin_toolkit_pct_months.max >= :value', value: months)
            .find_by('admin_toolkit_pct_costs.min <= :value AND admin_toolkit_pct_costs.max >= :value', value: cost)
        end
      end

      def prio_one?
        project_priority.try(:prio_one?)
      end

      def authorized?
        authorize! project, to: case aasm.to_state
                                when :technical_analysis_completed
                                  project.complex? ? :tac_complex? : 'technical_analysis_completed?'
                                when :unarchive then :archive?
                                else "#{aasm.to_state}?"
                                end
      end

      def extract_verdict
        verdict = attributes.dig(:verdicts, aasm.to_state)
        project.verdicts[aasm.to_state] = verdict if verdict.present?

        true
      end
    end
  end
end
