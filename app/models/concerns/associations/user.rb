# frozen_string_literal: true

module Associations
  module User
    extend ActiveSupport::Concern

    included do
      has_logidze

      belongs_to :role, counter_cache: true
      has_one :profile, inverse_of: :user, dependent: :destroy
      has_one :address, as: :addressable, inverse_of: :addressable, dependent: :destroy

      has_many :activities, foreign_key: :owner_id, dependent: :destroy
      has_many :involvements, foreign_key: :recipient_id, class_name: 'Activity', dependent: :destroy
      has_many :tasks, foreign_key: :owner_id, dependent: :restrict_with_exception, class_name: 'Projects::Task'
      has_many :assigned_tasks, foreign_key: :assignee_id, dependent: :restrict_with_exception,
                                class_name: 'Projects::Task'

      has_many :projects, foreign_key: :incharge_id, dependent: :restrict_with_exception
      has_many :assigned_projects, foreign_key: :assignee_id, dependent: :restrict_with_exception, class_name: 'Project'
      has_many :buildings, foreign_key: :assignee_id, dependent: :restrict_with_exception,
                           class_name: 'Projects::Building'

      has_many :kam_investors, foreign_key: :kam_id, dependent: :restrict_with_exception,
                               class_name: 'AdminToolkit::KamInvestor'
      has_many :kam_regions, foreign_key: :kam_id, dependent: :restrict_with_exception,
                             class_name: 'AdminToolkit::KamRegion'

      has_one_attached :activity_download
      has_one_attached :projects_download
      has_one_attached :building_download
      has_one_attached :contract_pdf_download

      accepts_nested_attributes_for :profile, :address, allow_destroy: true

      delegate :salutation, :name, :lastname, :firstname, to: :profile
      delegate :id, to: :profile, prefix: true
      delegate :id, to: :address, prefix: true, allow_nil: true
      delegate :permissions, :admin?, :nbo_team?, to: :role
      delegate :name, to: :role, prefix: true
    end
  end
end
