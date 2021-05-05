# frozen_string_literal: true

module Types
  class ActivityType < BaseObject
    field :id, ID, null: false
    field :created_at, GraphQL::Types::ISO8601DateTime, null: true
    field :display_text, String, null: true

    def display_text
      "Activities::#{activity_user.classify}"
        .constantize
        .new(current_user: current_user, attributes: { activity: object }).call
    end

    def activity_user
      case current_user.id
      when object.owner_id then 'owner'
      when object.recipient_id then 'recipient'
      else 'others'
      end
    end
  end
end
