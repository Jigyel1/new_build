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
        attributes.connection_costs_attributes.each do |attr|
          pct_calculator = ::Projects::PctCostCalculator.new(
            project_id: project.id,
            competition_id: project.competition_id,
            project_connection_cost: attr[:project_connection_cost],
            sockets: project.installation_detail.try(:sockets),
            connection_type: attr[:connection_type],
            cost_type: attr[:cost_type],
            connection_cost_id: attr[:connection_cost_id]
          )

          pct_calculator.call
        end
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
    end
  end
end
