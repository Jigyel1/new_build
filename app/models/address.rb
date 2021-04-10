# frozen_string_literal: true

class Address < ApplicationRecord
  belongs_to :addressable, polymorphic: true

  validates :street, :street_no, :city, :zip, presence: true
end
