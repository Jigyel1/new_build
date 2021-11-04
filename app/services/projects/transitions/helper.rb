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
        authorize! project, to: "#{aasm.to_state}?"
      end

      def unarchive?
        project.previous_status.to_sym == aasm.to_state
      end

      def extract_verdict
        verdict = attributes.dig(:verdicts, aasm.to_state)
        project.verdicts[aasm.to_state] = verdict if verdict.present?

        true
      end

      def record_activity
        with_tracking(activity_id = SecureRandom.uuid) do
          Activities::ActivityCreator.new(
            activity_id: activity_id,
            action: aasm.current_event,
            owner: current_user,
            trackable: project,
            parameters: parameters
          ).call
        end
      end

      def parameters
        {
          previous_status: project.previous_status.split('_').join(' '),
          status: project.status.split('_').join(' '),
          project_name: project.name
        }
      end

      # returns a list of states not relevant for the given project
      def irrelevant_states
        if marketing_only? then %i[technical_analysis_completed ready_for_offer]
        elsif prio_one? then :technical_analysis_completed
        end
      rescue NoMethodError # raised if the PCT cost for the project is not set
        nil
      end
    end
  end
end
