# frozen_string_literal: true

class Project < ApplicationRecord
  include Hooks::Project
  include Enumable::Project
  include Taskable

  # `assignee` would be the owner of the project.
  belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true

  # `incharge` will mainly be responsible for the updating the project status.
  belongs_to :incharge, class_name: 'Telco::Uam::User', optional: true

  belongs_to :kam_region, class_name: 'AdminToolkit::KamRegion', optional: true
  belongs_to :competition, class_name: 'AdminToolkit::Competition', optional: true

  has_one :address, as: :addressable, dependent: :destroy
  has_one :access_tech_cost, dependent: :destroy, class_name: 'Projects::AccessTechCost'
  has_one :installation_detail, dependent: :destroy, class_name: 'Projects::InstallationDetail'
  has_one :pct_cost, dependent: :destroy, class_name: 'Projects::PctCost'

  has_one(
    :default_label_group,
    -> { where(system_generated: true) },
    class_name: 'Projects::LabelGroup',
    dependent: :destroy
  )

  has_many :address_books, class_name: 'Projects::AddressBook', dependent: :destroy
  has_many :buildings, class_name: 'Projects::Building', dependent: :destroy
  has_many :tasks, as: :taskable, class_name: 'Projects::Task', dependent: :destroy
  has_many :label_groups, class_name: 'Projects::LabelGroup', dependent: :destroy

  has_many_attached :files, dependent: :destroy

  accepts_nested_attributes_for :address, :address_books, :access_tech_cost, :installation_detail, allow_destroy: true

  validates :address, presence: true
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

  # Project Nr - To be created by SELISE for manually created projects and imported projects.
  # This ID should start from the number '2' and in the format: eg: '2826123'
  def project_nr
    "2#{super}"
  end
end
