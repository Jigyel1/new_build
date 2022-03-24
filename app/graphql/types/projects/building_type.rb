# frozen_string_literal: true

module Types
  module Projects
    class BuildingType < BaseObject
      field :id, ID, null: true
      field :name, String, null: true
      field :external_id, String, null: true
      field :apartments_count, Int, null: true
      field :move_in_starts_on, String, null: true

      field :assignee, Types::UserType, null: true
      field :address, Types::AddressType, null: true
      field :project, Types::ProjectType, null: true, description: <<~DESC
        Just request for fields that are absolutely necessary. eg. ProjectId, Name etc.
      DESC

      field :tasks, String, null: true

      def tasks
        "#{object.completed_tasks_count}/#{object.tasks_count}"
      end
    end
  end
end
