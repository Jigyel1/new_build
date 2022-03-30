# frozen_string_literal: true

module Types
  module Projects
    class TaskType < BaseObject
      field :id, ID, null: true
      field :title, String, null: true
      field :status, String, null: true
      field :description, String, null: true
      field :building_id, String, null: true
      field :project_id, String, null: true
      field :project_name, String, null: true
      field :host_url, String, null: true

      field :assignee, Types::UserType, null: true
      field :owner, Types::UserType, null: true

      field :due_date, String, null: true
      def due_date
        in_time_zone(:due_date)
      end
    end
  end
end
