# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
  has_one :address, as: :addressable, dependent: :destroy

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
