# frozen_string_literal: true

module Types
  module Projects
    class TaskType < BaseObject
      field :id, ID, null: true
      field :title, String, null: true
      field :status, String, null: true
      field :description, String, null: true
      field :due_date, String, null: true

      field :assignee, Types::UserType, null: true
      field :owner, Types::UserType, null: true
    end
  end
end
