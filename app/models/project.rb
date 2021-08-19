# frozen_string_literal: true

class Project < ApplicationRecord
  self.inheritance_column = nil

  default_scope { where(draft: false) }

  belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true
  belongs_to :kam_region, class_name: 'AdminToolkit::KamRegion', optional: true

  has_one :address, as: :addressable, dependent: :destroy
  has_many :address_books, class_name: 'Projects::AddressBook', dependent: :destroy
  has_many :buildings, class_name: 'Projects::Building', dependent: :restrict_with_error

  accepts_nested_attributes_for :address, :address_books, allow_destroy: true

  validates :external_id, uniqueness: true, allow_nil: true

  ACCESSORS = %i[
    site_area
    base_area
    purpose
    main_category
    cat_code_01
    cat_text_01
    cat_art_01
    cat_code_02
    cat_text_02
    project_text_part_01
    project_text_part_02
    project_text_part_03
    proj_extern_id
    prod_id
    geocod_sccs
    coord_e
    coord_n
    regi_keyaccountmanager_name
  ].freeze

  store :additional_details, accessors: ACCESSORS, coder: JSON

  delegate :zip, to: :address

  def label_list=(value)
    return unless value

    entries = value.split(',').map(&:strip)
    entries << 'Manually Created' if manual?
    super(entries.uniq)
  end

  def label_list
    return super if super.present?

    AdminToolkit::LabelGroup.find_by!(code: status).label_list
  end

  # Project Nr - To be created by SELISE for manually created projects and imported projects.
  # This ID should start from the number '2' and in the format: eg: '2826123'
  def project_nr
    "2#{super}"
  end

  enum assignee_type: { kam: 'KAM Project', nbo: 'NBO Project' }
  enum entry_type: { manual: 'Manual', info_manager: 'Info Manager' }

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


