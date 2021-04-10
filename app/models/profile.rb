# frozen_string_literal: true

class Profile < ApplicationRecord
  EXPECTED_DIGITS_IN_PHONE = 10
  belongs_to :user, inverse_of: :profile, class_name: 'Telco::Uam::User'
  validates :salutation, :firstname, :lastname, :phone, presence: true

  enum salutation: { mr: 'Mr', ms: 'Ms' }

  # remove all special characters and keep the last 10 digits.
  def phone=(value)
    value && super(
      value.gsub(/\D/, '')
           .split('')
           .last(EXPECTED_DIGITS_IN_PHONE)
           .join
    )
  end
end
