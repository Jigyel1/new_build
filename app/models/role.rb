# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, inverse_of: :role, class_name: 'Telco::Uam::User', dependent: :restrict_with_error

  validates :name, presence: true

  enum name: {
    team_expert: 'NBO Team Expert',
    team_standard: 'NBO Team Standard',
    kam: 'Key Account Manager',
    presales: 'Presales Engineer',
    manager_nbo_kam: 'Manager NBO/KAM',
    manager_presales: 'Manager Presales',
    manager_commercialization: 'Commericialization Manager',
    management: 'Management',
    administrator: 'Administrator',
    super_user: 'Super User'
  }
end
