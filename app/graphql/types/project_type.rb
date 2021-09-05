# frozen_string_literal: true

module Types
  class ProjectType < BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :external_id, String, null: true
    field :internal_id, String, null: true

    field :project_nr, String, null: true
    field :status, String, null: true
    field :type, String, null: true
    field :category, String, null: true
    field :construction_type, String, null: true
    field :assignee_type, String, null: true

    field :assignee, Types::UserType, null: true
    field :address, Types::AddressType, null: true
    field :kam_region, AdminToolkit::KamRegionType, null: true
    field :address_books, [Projects::AddressBookType], null: true

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

    %w[status category type assignee_type].each do |enum|
      define_method enum do
        ::Project.send(enum.pluralize)[object.send(enum)]
      end
    end

    %i[move_in_starts_on move_in_ends_on construction_starts_on].each do |method_name|
      define_method method_name do
        in_time_zone(method_name)
      end
    end
  end
end
