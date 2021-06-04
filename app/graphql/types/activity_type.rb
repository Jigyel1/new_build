# frozen_string_literal: true

module Types
  class ActivityType < BaseObject
    include Activities::ActivityHelper
    using TimeFormatter

    field :id, ID, null: false
    field :created_at, String, null: true
    field :display_text, String, null: true
    field :action, String, null: true

    def created_at
      object.created_at.in_time_zone(context[:time_zone]).datetime_str
    end
  end
end
