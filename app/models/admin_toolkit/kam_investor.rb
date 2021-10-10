# frozen_string_literal: true

module AdminToolkit
  class KamInvestor < ApplicationRecord
    belongs_to :kam, class_name: 'Telco::Uam::User'

    validates :investor_id, presence: true, uniqueness: { case_sensitive: false }

    default_scope { order(:investor_id) }
  end
end
