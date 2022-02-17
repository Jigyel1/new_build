# frozen_string_literal: true

module Projects
  module Transitions
    class ConnectionCostValidator < BaseService
      attr_accessor :project
      attr_reader :connection_costs, :hfc_connection_cost, :project_connection_costs

      def initialize(args = {})
        super
        @connection_costs = args[:attributes]
        @hfc_connection_cost ||= project.connection_costs.hfc
        @project_connection_costs ||= project.connection_costs
      end

      def call
        validate_cost!
        archive_if_expensive!
        archive_hfc_only_if_expensive!
      end

      private

      def validate_cost!
        return unless connection_costs&.any? do |connection_cost|
          connection_cost['standard_cost'] && connection_cost['cost'].present?
        end

        raise(t('projects.transition.cost_present'))
      end

      # Currently only if both connections are <tt>too_expensive</tt> we archive the project.
      # But if the only connection is <tt>too_expensive</tt> we don't archive the project. They may
      # want the latter to change eventually.
      def archive_if_expensive!
        return unless project_connection_costs.size > 1 && project_connection_costs.all?(&:too_expensive?)

        archive_project
      end

      def archive_hfc_only_if_expensive!
        return unless project.standard? && hfc_connection_cost.exists?(cost_type: 'too_expensive')

        archive_project
      end

      def archive_project
        project.update!(status: :archived)
        raise(t('projects.transition.archiving_expensive_project'))
      end
    end
  end
end
