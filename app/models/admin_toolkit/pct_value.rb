# frozen_string_literal: true

module AdminToolkit
  class PctValue < ApplicationRecord
    belongs_to :pct_month
    belongs_to :pct_cost

    # validate index of the above two does not repeat

    enum status: {
      prio_1: 'Prio 1',
      prio_2: 'Prio 2',
      on_hold: 'On Hold'
    }
  end
end
