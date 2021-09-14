class Projects::InstallationDetail < ApplicationRecord
  belongs_to :project

  enum builder: { ll: 'LL', sunrise_upc: 'Sunrise UPC' }
end
