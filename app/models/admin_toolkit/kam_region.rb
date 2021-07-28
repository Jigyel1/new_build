class AdminToolkit::KamRegion < ApplicationRecord
  belongs_to :kam, class_name: 'Telco::Uam::User', optional: true

  validates :name, inclusion: { in: Rails.application.config.kam_regions }, uniqueness: { case_sensitive: false }
end
