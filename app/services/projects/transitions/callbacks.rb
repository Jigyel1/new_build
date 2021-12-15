# frozen_string_literal: true

module Projects
  module Transitions
    module Callbacks
      def after_transition_callback
        callback = "after_#{aasm.current_event}"
        send(callback) if respond_to?(callback)
      end

      def before_technical_analysis_completed
        extract_verdict

        # Project does not accept nested attribute for PCT Cost. So build the project
        # excluding the <tt>pct_cost_attributes</tt>
        project.assign_attributes(attributes.except(:pct_cost_attributes))

        Transitions::ConnectionCostValidator.new(
          project: project,
          attributes: attributes[:connection_costs_attributes]
        ).call

        Transitions::TacValidator.new(
          project: project,
          attributes: attributes
        ).call

        true
      end

      def after_technical_analysis_completed
        update_label unless marketing_only?
      end

      def after_ready_for_offer
        update_label
      end

      private

      delegate :default_label_group, to: :project

      # Remove any of the existing project priority status that is there in the default label group.
      # then add the current project priority status.
      # This is done so that the default label for the project only includes the priority status
      # that is relevant to the project based on its current status.
      #
      # Eg. Project A, qualified as a `Prio 1` project when it was initially moved to Technical Analysis Completed(TAC)
      # state. But it was reverted back to Technical Analysis, and before it was moved back to TAC, cost were
      # updated such that the project now is an `On Hold` project. The project should no longer have `Prio 1` as a
      # label in it's default label group.
      #
      def update_label # rubocop:disable Metrics/AbcSize
        default_label_group.label_list.delete_if { |label| AdminToolkit::PctValue.statuses.value?(label) }

        default_label_group.label_list << AdminToolkit::PctValue.statuses[project_priority.status]
        default_label_group.save!
      rescue StandardError => e
        raise(t('projects.transition.error_while_adding_label', error: e.message))
      end
    end
  end
end
