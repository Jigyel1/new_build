# frozen_string_literal: true

module AdminToolkit
  class Penetration < ApplicationRecord
    self.inheritance_column = nil

    belongs_to :kam_region, class_name: 'AdminToolkit::KamRegion'
    has_many :penetration_competitions, class_name: 'AdminToolkit::PenetrationCompetition', dependent: :destroy
    has_many :competitions, through: :penetration_competitions

    accepts_nested_attributes_for :penetration_competitions, allow_destroy: true

    validates :city, :zip, :rate, :type, presence: true
    validates :hfc_footprint, inclusion: { in: [true, false] }
    validates :rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true
    validates :zip, uniqueness: { case_sensitive: false }

    enum type: {
      top_city: 'Top City',
      land: 'Land',
      agglo: 'Agglo',
      med_city: 'Med City'
    }

    enum strategic_partner: {
      cable_group: 'Cable Group',
      isen_tiefbau: 'Isen Tiefbau',
      cablex_zh: 'Cablex ZH',
      cablex_romandie: 'Cablex Romandie',
      cablex_ticino: 'Cablex Ticino'
    }

    default_scope { order(:zip) }

    after_destroy :update_project!, :update_projects_list
    after_save :update_project!, :update_projects_list

    private

    def update_project!
      Address.where(zip: zip, addressable_type: 'Project').find_each do |address|
        project = address.addressable
        project.update!(strategic_partner: strategic_partner)
      end
    end
  end
end
