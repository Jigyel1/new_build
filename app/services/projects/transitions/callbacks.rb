# frozen_string_literal: true

module Projects
  module Transitions
    module Callbacks
      # TODO: Create a label group - open for a project right after it is created.
      # TODO: create a label group for the project once the project transitions in to that state.
      #   After every transition, log activity, clear draft_version

      def after_open
        # byebug
      end

      def after_technical_analysis
        # byebug
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
