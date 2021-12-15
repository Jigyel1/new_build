# frozen_string_literal: true

module Projects
  module Transitions
    class TacValidator < BaseService
      attr_accessor :project

      def initialize(args = {})
        super
        @attributes = OpenStruct.new(args[:attributes])
      end

      def call
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

      def validate_in_house_installation!
        if attributes.in_house_installation
          return if installation_details?

          raise(t('projects.transition.missing_inhouse_installation_details'))
        else
          return unless installation_details?

          raise(t('projects.transition.inhouse_installation_details_not_supported'))
        end
      end

      def installation_details?
        @_installation_details ||= attributes.installation_detail_attributes.present?
      end

      def project_connection_cost
        @_project_connection_cost ||= attributes.pct_cost_attributes.try(:[], :project_connection_cost)
      end
    end
  end
end
