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
      in_datetime_zone(:created_at)
    end

    def in_datetime_zone(method, format: :datetime_str)
      return unless object.send(method)

      object.send(method).send(format)
    end
  end
end
