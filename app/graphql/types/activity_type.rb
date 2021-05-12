# frozen_string_literal: true

module Types
  class ActivityType < BaseObject
    include Activities::ActivityHelper

    field :id, ID, null: false
    field :created_at, String, null: true
    field :display_text, String, null: true

    def created_at
      formatted_datetime(object.created_at)
    end
  end
end
