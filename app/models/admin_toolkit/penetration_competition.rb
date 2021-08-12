class AdminToolkit::PenetrationCompetition < ApplicationRecord
  belongs_to :penetration
  belongs_to :competition

  # validates :competition_id, uniqueness: { scope: :penetration_id }
end
