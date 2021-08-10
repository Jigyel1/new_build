# frozen_string_literal: true

module Types
  class ProjectType < BaseObject
    using TimeFormatter

    field :id, ID, null: false
    field :name, String, null: true
    field :external_id, String, null: true
    field :landlord_id, String, null: true

    field :project_nr, String, null: true
    field :status, String, null: true
    field :type, String, null: true
    field :category, String, null: true
    field :construction_type, String, null: true
    field :assignee_type, String, null: true

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
    field :buildings, Int, null: true
    field :apartments, Int, null: true
    field :settings, GraphQL::Types::JSON, null: true

    field :assignee, Types::UserType, null: true

    def status
      ::Project.statuses[object.status]
    end

    def category
      ::Project.categories[object.category]
    end

    def type
      ::Project.types[object.type]
    end

    def assignee_type
      ::Project.assignee_types[object.assignee_type]
    end

    def move_in_starts_on
      object.move_in_starts_on.in_time_zone(context[:time_zone]).date_str
    end
  end
end
