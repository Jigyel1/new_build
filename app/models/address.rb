# frozen_string_literal: true

class Address < ApplicationRecord
  has_logidze

  belongs_to :addressable, polymorphic: true

  validates(
    :street, :street_no, :city, :zip,
    presence: true,
    unless: ->(record) { [Projects::AddressBook, Projects::Building].any? { |klass| record.addressable.is_a?(klass) } }
  )

  with_options if: ->(record) { record.addressable.is_a?(Project) } do
    after_save :update_projects_list
    after_destroy :update_projects_list
  end

  def street_with_street_no
    "#{street} #{street_no}".squish
  end
end
