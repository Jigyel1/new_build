# frozen_string_literal: true

class Project < ApplicationRecord
  self.inheritance_column = nil

  belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
  belongs_to :kam_region, class_name: 'AdminToolkit::KamRegion', optional: true

  has_one :address, as: :addressable, dependent: :destroy
  has_many :address_books, class_name: 'Projects::AddressBook', dependent: :destroy
  accepts_nested_attributes_for :address, :address_books, allow_destroy: true

  validates :external_id, uniqueness: true, allow_nil: true
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

  def label_list=(value)
    return unless value

    super(value.split(',').map(&:strip).uniq)
  end

  def label_list
    super || AdminToolkit::LabelGroup.find_by!(code: status).label_list
  end

  enum assignee_type: { kam: 'KAM Project', nbo: 'NBO Project' }

  enum status: {
    technical_analysis: 'Technical Analysis',
    pct_calculation: 'PCT Calculation',
    technical_analysis_completed: 'Technical Analysis Completed/On-Hold Meeting',
    ready_for_offer: 'Ready for Offer',
    contract: 'Contract',
    contract_accepted: 'Contract Accepted',
    under_construction: 'Under Construction'
  }

  # 'Marketing only' and 'Irrelevant' to be added later.
  enum category: {
    standard: 'Standard',
    complex: 'Complex'
  }

  enum type: {
    proactive: 'Proactive',
    reactive: 'Reactive',
    customer_request: 'Customer Request'
  }

  enum construction_type: {
    reconstruction: 'Reconstruction',
    new_construction: 'New Construction',
    b2b_new: 'B2B (New)',
    b2b_reconstruction: 'B2B (Reconstruction)',
    overbuild: 'Overbuild'
  }
end
