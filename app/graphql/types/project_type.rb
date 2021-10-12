# frozen_string_literal: true

module Types
  class ProjectType < BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :external_id, String, null: true
    field :internal_id, String, null: true
    field :os_id, String, null: true

    field :project_nr, String, null: true
    field :status, String, null: true
    field :priority, String, null: true
    field :category, String, null: true
    field :construction_type, String, null: true
    field :assignee_type, String, null: true
    field :entry_type, String, null: true

    field :verdicts, GraphQL::Types::JSON, null: true

    field :assignee, Types::UserType, null: true
    field :incharge, Types::UserType, null: true
    field :address, Types::AddressType, null: true
    field :kam_region, AdminToolkit::KamRegionType, null: true
    field :address_books, [Projects::AddressBookType], null: true
    field :pct_cost, Types::Projects::PctCostType, null: true

    field :access_tech_cost, Types::Projects::AccessTechCostType, null: true
    field :installation_detail, Types::Projects::InstallationDetailType, null: true
    field :access_technology, String, null: true
    field :analysis, String, null: true
    field :competition, Types::AdminToolkit::CompetitionType, null: true
    field :customer_request, Boolean, null: true
    field :in_house_installation, Boolean, null: true
    field :standard_cost_applicable, Boolean, null: true
    field :system_sorted_category, Boolean, null: true

    field(
      :move_in_starts_on,
      String,
      null: true,
      description: 'From when the tenant can move in.'
    )

    field(
      :move_in_ends_on,
      String,
      null: true,
      description: 'Till when the tenant can move in.'
    )

    field :construction_starts_on, String, null: true

    field :lot_number, String, null: true
    field :buildings_count, Int, null: true
    field :apartments_count, Int, null: true
    field :coordinate_east, Float, null: true
    field :coordinate_north, Float, null: true
    field :description, String, null: true
    field :additional_info, String, null: true
    field :additional_details, GraphQL::Types::JSON, null: true
    field :label_list, [String], null: true
    field :draft_version, GraphQL::Types::JSON, null: true

    field :default_label_group, Types::Projects::LabelGroupType, null: true

    %i[move_in_starts_on move_in_ends_on construction_starts_on].each do |method_name|
      define_method method_name do
        in_time_zone(method_name)
      end
    end

    field :states, GraphQL::Types::JSON, null: true, description: <<~DESC
      This will be a list statuses that the given project supports.
    DESC
    def states
      ::Projects::StateMachine.new(attributes: { id: object.id }).states
    end

    field :current_label_group, Types::Projects::LabelGroupType, null: true
    def current_label_group
      object.label_groups.joins(:label_group).find_by(
        admin_toolkit_label_groups: { code: object.status }
      )
    end

    field :gis_url, String, null: true
    field :info_manager_url, String, null: true
  end
end
