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
  end
end
