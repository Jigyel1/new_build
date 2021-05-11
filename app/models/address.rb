# frozen_string_literal: true

class Address < ApplicationRecord
  has_logidze

  belongs_to :addressable, polymorphic: true

  validates :street, :street_no, :city, :zip, presence: true
end
