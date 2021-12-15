# frozen_string_literal: true

module Associations
  module Project
    extend ActiveSupport::Concern

    included do
      # `assignee` would be the owner of the project.
      belongs_to :assignee, class_name: 'Telco::Uam::User', optional: true

      # `incharge` will mainly be responsible for the updating the project status.
      belongs_to :incharge, class_name: 'Telco::Uam::User', optional: true

      belongs_to :kam_region, class_name: 'AdminToolkit::KamRegion', optional: true
      belongs_to :competition, class_name: 'AdminToolkit::Competition', optional: true

      has_one :address, as: :addressable, dependent: :destroy
      has_one :installation_detail, dependent: :destroy, class_name: 'Projects::InstallationDetail'
      has_one :pct_cost, dependent: :destroy, class_name: 'Projects::PctCost'

      has_one(
        :default_label_group,
        -> { where(system_generated: true) },
        class_name: 'Projects::LabelGroup',
        dependent: :destroy
      )

      has_many :connection_costs, dependent: :destroy, class_name: 'Projects::ConnectionCost'
      has_many :address_books, class_name: 'Projects::AddressBook', dependent: :destroy
      has_many :buildings, class_name: 'Projects::Building', dependent: :destroy
      has_many :tasks, as: :taskable, class_name: 'Projects::Task', dependent: :destroy
      has_many :label_groups, class_name: 'Projects::LabelGroup', dependent: :destroy

      has_many_attached :files, dependent: :destroy

      accepts_nested_attributes_for(
        :address,
        :address_books,
        :connection_costs,
        :installation_detail,
        allow_destroy: true
      )
    end
  end
end
