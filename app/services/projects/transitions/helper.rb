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

      def pct_value
        @_pct_value ||= Projects::PctFinder.new(project: project, type: 'pct_value').call
      end

      def prio_one?
        default_label_group.label_list.any?('Prio 1')
      end

      # Special check for <tt>Prio 1</tt> projects - those that can be transitioned from <tt>technical_analysis</tt>
      # to <tt>ready_for_offer</tt> where instead of checking if user has the permission to transition to
      # <tt>ready_for_offer</tt>, we check if the user has the permission to transition to
      # <tt>technical_analysis_completed</tt>
      def authorized?
        if technical_analysis_to_offer?
          authorize! project, to: 'technical_analysis_completed?'
        else
          authorize! project, to: "#{aasm.to_state}?"
        end
      end

      def technical_analysis_to_offer?
        aasm.from_state == :technical_analysis && aasm.to_state == :ready_for_offer
      end

      def unarchive?
        authorize! project, to: :unarchive?

        project.previous_status.to_sym == aasm.to_state
      end

      def revert?
        user.admin? ? true : (authorize! project, to: "#{aasm.from_state}?")
      end

      def extract_verdict
        verdict = attributes.dig(:verdicts, aasm.to_state)
        project.verdicts[aasm.from_state] = verdict if verdict.present?

        project.save!
      end

      def clear_tac
        project.update!(verdicts: nil, access_technology_tac: nil, priority_tac: nil)
      end

      def set_default_status
        project.update!(confirmation_status: :new_offer)
      end

      def update_tac_attributes
        project.update_columns(
          attributes.slice(:priority_tac, :access_technology_tac)
        )
      end

      def record_activity(&block)
        with_tracking(&block)
      end

      def activity_params
        {
          action: aasm.current_event,
          owner: current_user,
          trackable: project,
          parameters: {
            previous_status: project.previous_status.humanize(capitalize: false),
            status: project.status.humanize(capitalize: false),
            project_name: project.name
          }
        }
      end

      # returns a list of states not relevant for the given project
      def irrelevant_states
        if marketing_only?
          %i[technical_analysis_completed ready_for_offer]
        elsif prio_one?
          :technical_analysis_completed
        end
      rescue NoMethodError # raised if the PCT cost for the project is not set
        nil
      end

      def assign_incharge
        project.incharge || project.update!(incharge: current_user)
      end

      def remove_status
        project.update!(confirmation_status = nil)
      end
    end
  end
end
