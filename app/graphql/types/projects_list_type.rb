# frozen_string_literal: true

# TODO:
#   Add labels count
module Types
  class ProjectsListType < BaseObject
    field :id, ID, null: true
    field :external_id, String, null: true
    field :project_nr, String, null: true
    field :name, String, null: true
    field :category, String, null: true
    field :type, String, null: true
    field :construction_type, String, null: true

    field :move_in_starts_at, String, null: true
    field :move_in_ends_at, String, null: true
    field :buildings_count, Int, null: true
    field :apartments_count, Int, null: true
    field :labels, Int, null: true
    field :lot_number, String, null: true

    field :address, String, null: true
    field :landlord, String, null: true
    field :assignee, String, null: true
    field :kam_region, String, null: true
  end
end

