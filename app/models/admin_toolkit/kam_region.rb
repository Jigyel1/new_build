# frozen_string_literal: true

module AdminToolkit
  class KamRegion < ApplicationRecord
    belongs_to :kam, class_name: 'Telco::Uam::User', optional: true
    has_many :penetrations, class_name: 'AdminToolkit::Penetration', dependent: :restrict_with_error

    validates(
      :name,
      presence: true,
      inclusion: { in: Rails.application.config.kam_regions },
      uniqueness: { case_sensitive: false }
    )
  end
end
