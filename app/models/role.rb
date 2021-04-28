# frozen_string_literal: true

class Role < ApplicationRecord
  PERMISSIONS = HashWithIndifferentAccess.new(
    YAML.safe_load(
      File.read(
        File.join(Rails.root, 'config', 'permissions.yml')
      )
    )
  ).freeze

  has_many :users, class_name: 'Telco::Uam::User', dependent: :restrict_with_error
  has_many :profiles, through: :users
  has_many :permissions, as: :accessor, dependent: :destroy

  accepts_nested_attributes_for :permissions

  validates :name, presence: true, uniqueness: true

  # admin & super_user are the general admins of the portal.
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
