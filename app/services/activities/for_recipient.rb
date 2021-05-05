# frozen_string_literal: true

module Activities
  class ForRecipient < BaseService
    include ActivityHelper

    def call
      case activity.verb.to_sym
      when :status_updated
        t(
          "activities.#{activity.trackable_type.downcase}.status_updated.recipient",
          owner_email: activity.owner.email,
          active: parameters.active
        )
      end
    end
  end
end
