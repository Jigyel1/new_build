# frozen_string_literal: true

module AdminToolkit
  class KamMapping < ApplicationRecord
    belongs_to :kam, class_name: 'Telco::Uam::User'

    validates :investor_id, presence: true, uniqueness: { case_sensitive: false }
  end
end
