# frozen_string_literal: true

module Projects
  module Transitions
    module Callbacks
      def after_transition_callback
        callback = "after_#{aasm.current_event}"
        send(callback) if respond_to?(callback)
      end

      def before_technical_analysis_completed
        # Project does not accept nested attribute for PCT Cost. So extract and remove
        # the necessary attributes before assigning those to the project.
        pct_cost = OpenStruct.new(attributes.delete(:pct_cost_attributes))

        extract_verdict
        project.assign_attributes(attributes)

        Transitions::TacValidator.new(
          project: project,
          project_connection_cost: pct_cost.project_connection_cost
        ).call

        true
      end

      def after_technical_analysis_completed
        update_label
      end

      def after_ready_for_offer
        update_label
      end

      private

      def update_label
        label_group = AdminToolkit::LabelGroup.find_by!(code: project.status)

        project_label_group = project.label_groups.find_or_create_by!(label_group: label_group)
        project_label_group.label_list << AdminToolkit::PctValue.statuses[project_priority.status]
        project_label_group.save!
      rescue StandardError => e
        raise(t('projects.transition.error_while_adding_label', error: e.message))
      end
    end
  end
end
