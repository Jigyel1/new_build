# frozen_string_literal: true

module Projects
  module Transitions
    class ConnectionCostValidator < BaseService
      attr_accessor :project
      attr_reader :connection_costs

      def initialize(args = {})
        super
        @connection_costs = args[:attributes]
      end

      def call
        validate_cost!
        validate_by_project_category!
        archive_expensive_projects!
      end

      private

      def validate_cost!
        return unless connection_costs&.any? do |connection_cost|
          connection_cost['standard_cost'] && connection_cost['cost'].present?
        end

        raise(t('projects.transition.cost_present'))
      end

      def validate_by_project_category!
        return unless project.standard? && project.connection_costs.any?(&:ftth?)

        raise(t('projects.transition.ftth_not_supported'))
      end

      def archive_expensive_projects!
        return unless project.connection_costs.size > 1 && project.connection_costs.all?(&:too_expensive?)

        project.update!(category: :irrelevant, status: :archived)
        raise(t('projects.transition.archiving_expensive_project'))
      end
    end
  end
end
