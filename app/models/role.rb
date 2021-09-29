# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :users, class_name: 'Telco::Uam::User', dependent: :restrict_with_error
  has_many :profiles, through: :users
  has_many :permissions, as: :accessor, dependent: :destroy

  accepts_nested_attributes_for :permissions

  after_save :update_users_list
  after_destroy :update_users_list

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  default_scope { order(:name) }

  # admin & super_user are the general admins of the portal.
  enum name: {
    team_expert: 'NBO Team Expert',
    team_standard: 'NBO Team Standard',
    kam: 'Key Account Manager',
    presales: 'Presales Engineer',
    manager_nbo_kam: 'Manager NBO/KAM',
    manager_presales: 'Manager Presales',
    manager_commercialization: 'Commercialization Manager',
    management: 'Management',
    administrator: 'Administrator',
    super_user: 'Super User'
  }

  def admin?
    %w[administrator super_user].any?(name)
  end

  def nbo_team?
    team_expert? || team_standard?
  end

  # Overriding the default enum behaviour to return the first role when called with
  # an enum key.
  # eg. Role.kam returns the first matching role and not an array.
  #
  Role.names.each_key do |name|
    singleton_class.define_method name do
      Role.find_by(name: name)
    end
  end
end
