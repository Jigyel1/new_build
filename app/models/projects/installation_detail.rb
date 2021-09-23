# frozen_string_literal: true

module Projects
  class InstallationDetail < ApplicationRecord
    belongs_to :project

    enum builder: { ll: 'LL', sunrise_upc: 'Sunrise UPC' }
  end
end
