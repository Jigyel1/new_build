# frozen_string_literal: true

class Address < ApplicationRecord
  has_logidze

  belongs_to :addressable, polymorphic: true

  validates :street, :street_no, :city, :zip, presence: true, if: ->(record) { record.addressable.is_a?(User) }

  def street_with_street_no
    "#{street} #{street_no}".squish
  end
end
