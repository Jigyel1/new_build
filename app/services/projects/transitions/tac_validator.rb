# frozen_string_literal: true

module Projects
  module Transitions
    class TacValidator < BaseService
      attr_accessor :project, :project_connection_cost

      def call
        validate_access_technology!
        validate_in_house_installation!
        calculate_pct!
      end

      private

      def calculate_pct!
        pct_calculator = ::Projects::PctCostCalculator.new(
          project_id: project.id,
          competition_id: project.competition_id,
          project_connection_cost: project_connection_cost,
          sockets: project.installation_detail.try(:sockets)
        )
        pct_calculator.call
        project.pct_cost = pct_calculator.pct_cost
      rescue RuntimeError => e
        raise(t('projects.transition.error_in_pct_calculation', error: e.message))
      end

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
