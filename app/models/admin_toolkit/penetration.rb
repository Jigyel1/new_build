class AdminToolkit::Penetration < ApplicationRecord
  self.inheritance_column = nil

  validates :city, :zip, :rate, :kam_region, :type, presence: true
  validates :hfc_footprint, inclusion: { in: [ true, false ] }
  validates :kam_region, inclusion: { in: Rails.application.config.kam_regions }
  validates :rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_blank: true
  validates :zip, uniqueness: true

  enum competition: {
    ftth_swisscom: 'FTTH Swisscom',
    ftth_sfn: 'FTTH SFN',
    f_fast: 'f.fast',
    vdsl: 'VDSL'
  }

  enum type: {
    top_city: 'Top City',
    land: 'Land',
    agglo: 'Agglo',
    med_city: 'Med City'
  }
end
