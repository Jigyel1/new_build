# frozen_string_literal: true

module AdminToolkit
  class PenetrationCompetition < ApplicationRecord
    belongs_to :penetration
    belongs_to :competition
  end
end
