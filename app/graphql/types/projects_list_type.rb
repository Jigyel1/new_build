# frozen_string_literal: true

module Types
  class ProjectsListType < BaseObject
    field :id, ID, null: true
    field :external_id, String, null: true
    field :project_nr, String, null: true
    field :name, String, null: true
    field :status, String, null: true
    field :category, String, null: true
    field :priority, String, null: true
    field :construction_type, String, null: true

    field :move_in_starts_on, String, null: true
    field :move_in_ends_on, String, null: true
    field :buildings_count, Int, null: true
    field :apartments_count, Int, null: true
    field :labels, Int, null: true
    field :label_list, [String], null: true
    field :lot_number, String, null: true
    field :customer_request, Boolean, null: true

    field :address, String, null: true
    field :investor, String, null: true
    field :assignee, String, null: true
    field :kam_region, String, null: true

    field :draft_version, GraphQL::Types::JSON, null: true
  end
end
