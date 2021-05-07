# frozen_string_literal: true

module ActivitiesFormatter
  class ForOwner < BaseService
    include ActivityHelper

    def call # rubocop:disable Metrics/AbcSize, Metrics/SeliseMethodLength
      case activity.verb.to_sym
      when :status_updated
        t(
          'activities.user.status_updated.owner',
          recipient_email: log_data.recipient_email,
          action: action.camelize
        )
      when :user_invited
        t(
          'activities.user.user_invited.owner',
          recipient_email: log_data.recipient_email,
          role: parameters.role
        )
      when :profile_updated
        t(
          'activities.user.profile_updated.owner',
          recipient_email: log_data.recipient_email
        )
      when :profile_deleted
        t(
          'activities.user.profile_deleted.owner',
          recipient_email: log_data.recipient_email
        )
      when :role_updated
        t(
          'activities.user.role_updated.owner',
          recipient_email: log_data.recipient_email,
          role: parameters.role,
          previous_role: parameters.previous_role
        )
      end
    end
  end
end
