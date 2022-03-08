# frozen_string_literal: true

module Types
  module Projects
    class PctCostType < BaseObject
      include ActionView::Helpers::TextHelper

      # To avoid name conflict with the `PctCostType` defined in the `AdminToolkit`
      graphql_name 'ProjectsPctCostType'

      field :id, ID, null: true
      field :project_cost, Float, null: true
      field :socket_installation_cost, Float, null: true
      field :lease_cost, Float, null: true
      field :build_cost, Float, null: true
      field :roi, Float, null: true
      field :project_connection_cost, Float, null: true

      field :payback_period, Float, null: true, description: 'In Years'
      field :system_generated_payback_period, Boolean, null: true

      field :payback_period_formatted, String, null: true

      def payback_period_formatted
        years = object.payback_period.round(2)

        I18n.t('projects.payback_period.years', years: years)
      end

      field :penetration_rate, Float, null: true
      def penetration_rate
        object.penetration_rate.try(:rounded)
      end
    end
  end
end
