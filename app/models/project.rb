# frozen_string_literal: true

class Project < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
  belongs_to :kam_region, class_name: 'AdminToolkit::KamRegion', optional: true

  has_one :address, as: :addressable, dependent: :destroy
  has_many :address_books, class_name: 'Projects::AddressBook', dependent: :destroy
  accepts_nested_attributes_for :address, :address_books, allow_destroy: true

  validates :external_id, uniqueness: true
  validates :buildings, :apartments, numericality: { greater_than: 0 }, allow_nil: true
  validates(
    :apartments,
    numericality: {
      greater_than_or_equal_to: :buildings,
      message: 'should be greater than or equal to the buildings.'
    },
    allow_nil: true
  )

  delegate :zip, to: :address

  enum assignee_type: { kam: 'KAM Project', nbo: 'NBO Project' }
  enum status: {
    technical_analysis: 'Technical Analysis',
    technical_analysis_complete: 'Technical Analysis Complete',
    ready_to_offer: 'Ready to Offer',
    commercialization: 'Commercialization'
  }

  enum category: {
    standard: 'Standard',
    complex: 'Complex',
    marketing: 'Marketing only',
    irrelevant: 'Irrelevant'
  }

  enum type: {
    proactive: 'Proactive',
    reactive: 'Reactive'
  }
end
