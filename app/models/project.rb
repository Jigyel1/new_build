# frozen_string_literal: true

class Project < ApplicationRecord
  include Accessors::Project
  include Associations::Project
  include Hooks::Project
  include Enumable::Project
  include Trackable

  validates :address, presence: true
  validates :external_id, uniqueness: true, allow_nil: true

  validates :move_in_starts_on, succeeding_date: { preceding_date_key: :construction_starts_on }, allow_nil: true
  validates :move_in_ends_on, succeeding_date: { preceding_date_key: :move_in_starts_on }, allow_nil: true

  delegate :zip, to: :address
  delegate :project_cost, to: :pct_cost, allow_nil: true
  delegate :email, to: :incharge, prefix: true, allow_nil: true

  # Project Nr - To be created by SELISE for manually created projects and imported projects.
  # This ID should start from the number '2' and in the format: eg: '2826123'
  def project_nr
    "2#{super}"
  end
end
