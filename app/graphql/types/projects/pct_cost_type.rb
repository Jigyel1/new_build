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
      field :arpu, Float, null: true
      field :lease_cost, Float, null: true
      field :project_connection_cost, Float, null: true
      field :penetration_rate, Float, null: true

      field :payback_period, Int, null: true, description: 'In months'
      field :system_generated_payback_period, Boolean, null: true

      field :payback_period_formatted, String, null: true
      def payback_period_formatted
        seconds = ActiveSupport::Duration::SECONDS_PER_MONTH * object.payback_period
        to_text(ActiveSupport::Duration.build(seconds).parts)
      end

      private

      def to_text(parts)
        years, months = parts.values_at(:years, :months)

        text_array = []
        text_array << pluralize(years, 'year') if years
        text_array << pluralize(months, 'month') if months
        text_array.join(' and ')
      end
    end
  end
end
