# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true

  has_one :address, as: :addressable, dependent: :destroy
  has_many :address_books, class_name: 'Projects::AddressBook', dependent: :destroy
  accepts_nested_attributes_for :address, :address_books, allow_destroy: true

  validates :buildings, :apartments, numericality: { greater_than: 0 }
  validates :apartments, numericality: { greater_than: :buildings }

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
