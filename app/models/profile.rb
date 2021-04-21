# frozen_string_literal: true

class Profile < ApplicationRecord
  has_logidze

  EXPECTED_DIGITS_IN_PHONE = 10
  VALID_DEPARTMENTS = YAML.safe_load(
    File.read(
      Rails.root.join('config/departments.yml')
    )
  ).freeze

  belongs_to :user, inverse_of: :profile, class_name: 'Telco::Uam::User'
  validates :salutation, :firstname, :lastname, :phone, presence: true
  validates :department, inclusion: { in: VALID_DEPARTMENTS }, allow_nil: true

  enum salutation: { mr: 'Mr', ms: 'Ms' }

  # remove all special characters and keep the last 10 digits.
  def phone=(value)
    value && super(
      value.gsub(/\D/, '')
           .split('') # rubocop:disable Style/StringChars
           .last(EXPECTED_DIGITS_IN_PHONE)
           .join
    )
  end

  def name
    [firstname, lastname].join(' ')
  end
end
