# frozen_string_literal: true

module Projects
  module Transitions
    module Callbacks
      def after_transition_callback
        callback = "after_#{aasm.current_event}"
        send(callback) if respond_to?(callback)
      end

      def before_technical_analysis_completed # rubocop:disable Metrics/SeliseMethodLength, Metrics/AbcSize
        extract_verdict

        # Project does not accept nested attribute for Connection Costs. So build the project
        # excluding the <tt>pct_cost_attributes</tt>
        project.assign_attributes(attributes.except(:connection_costs_attributes))

        Transitions::TacValidator.new(
          project: project,
          attributes: attributes
        ).call

        Transitions::ConnectionCostValidator.new(
          project: project,
          attributes: attributes[:connection_costs_attributes]
        ).call

        update_label unless marketing_only?
        update_exceeding_cost
        true
      end

      def after_technical_analysis_completed
        calculate_pct!
        update_exceeding_cost
        update_label unless marketing_only?
      end

      def after_offer_ready
        update_tac_attributes
        update_label
      end

      private

      def calculate_pct! # rubocop:disable Metrics::AbcSize, Metrics/SeliseMethodLength
        return if project.in_house_installation?

        project.connection_costs.find_each do |connection_cost|
          project_connection_cost = if connection_cost.standard?
                                      nil
                                    else
                                      connection_cost.pct_cost.try(:project_connection_cost)
                                    end

          ::Projects::PctCostCalculator.new(
            project_id: project.id,
            competition_id: project.reload.competition_id,
            project_connection_cost: project_connection_cost,
            sockets: 0,
            connection_type: connection_cost.connection_type,
            cost_type: connection_cost.cost_type,
            connection_cost_id: connection_cost.id
          ).call
        end
      end

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

        default_label_group.label_list << AdminToolkit::PctValue.statuses[pct_value.status]
        update_prio_status(AdminToolkit::PctValue.statuses[pct_value.status])
        default_label_group.save!
      rescue StandardError => e
        raise(t('projects.transition.error_while_adding_label', error: e.message))
      end

      def update_exceeding_cost
        project.update!(exceeding_cost: ::AdminToolkit::CostThreshold.first.exceeding)
      end

      def update_prio_status(status)
        project.update!(prio_status: status)
      end
    end
  end
end
