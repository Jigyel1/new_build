# frozen_string_literal: true

class Profile < ApplicationRecord
  has_logidze

  VALID_DEPARTMENTS = YAML.safe_load(
    File.read(
      Rails.root.join('config/departments.yml')
    )
  ).freeze

  belongs_to :user, inverse_of: :profile, class_name: 'Telco::Uam::User'
  validates :salutation, :firstname, :lastname, :phone, presence: true
  validates :department, inclusion: { in: VALID_DEPARTMENTS }, allow_nil: true

  has_one_attached :avatar, dependent: :destroy

  enum salutation: { mr: 'Mr', ms: 'Ms' }

  def name
    [firstname, lastname].join(' ')
  end
end
