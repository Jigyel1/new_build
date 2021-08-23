# frozen_string_literal: true

module AdminToolkit
  class PctValue < ApplicationRecord
    belongs_to :pct_month
    belongs_to :pct_cost

    validates :status, presence: true, uniqueness: { scope: %i[pct_cost_id pct_month_id] }

    enum status: {
      prio_one: 'Prio 1',
      prio_two: 'Prio 2',
      on_hold: 'On Hold'
    }

    # TODO: Add index for this in the migration
    default_scope do
      joins(:pct_month, :pct_cost)
        .order('admin_toolkit_pct_months.index, admin_toolkit_pct_costs.index')
    end
  end
end
