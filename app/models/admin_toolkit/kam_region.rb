# frozen_string_literal: true

module AdminToolkit
  class KamRegion < ApplicationRecord
    belongs_to :kam, class_name: 'Telco::Uam::User', optional: true

    validates(
      :name,
      presence: true,
      inclusion: { in: Rails.application.config.kam_regions },
      uniqueness: { case_sensitive: false }
    )
  end
end
