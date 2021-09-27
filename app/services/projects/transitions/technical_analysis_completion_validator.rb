# frozen_string_literal: true

module Projects
  module Transitions
    class TechnicalAnalysisCompletionValidator < BaseService
      attr_accessor :project

      def call
        validate_access_technology!
        validate_in_house_installation!
      end

      private

      # FIXME: This logic needs to be fixed.
      def validate_access_technology!
        return unless project.standard_cost_applicable

        project.ftth? && raise(t('projects.transition.ftth_not_supported'))
        project.access_tech_cost && raise(t('projects.transition.access_tech_cost_not_supported'))
      end

      def validate_in_house_installation!
        if project.in_house_installation
          return if project.installation_detail

          raise(t('projects.transition.missing_inhouse_installation_details'))
        else
          return unless project.installation_detail

          raise(t('projects.transition.inhouse_installation_details_not_supported'))
        end
      end
    end
  end
end
