# frozen_string_literal: true

class Profile < ApplicationRecord
  has_logidze

  belongs_to :user, inverse_of: :profile, class_name: 'Telco::Uam::User'
  validates :salutation, :firstname, :lastname, :phone, presence: true
  validates :department, inclusion: { in: Rails.application.config.user_departments }, allow_nil: true

  has_one_attached :avatar, dependent: :destroy

  enum salutation: { mr: 'Mr', ms: 'Ms' }

  after_save :update_users_list, :update_projects_list
  after_destroy :update_users_list, :update_projects_list

  def name
    [firstname, lastname].join(' ')
  end
end
