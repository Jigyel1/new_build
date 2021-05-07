# frozen_string_literal: true

module ActivitiesFormatter
  class ForOthers < BaseService
    include ActivityHelper

    def call # rubocop:disable Metrics/AbcSize, Metrics/SeliseMethodLength
      case activity.verb.to_sym
      when :status_updated
        t(
          'activities.user.status_updated.others',
          owner_email: log_data.owner_email,
          recipient_email: log_data.recipient_email,
          action: action
        )
      when :user_invited
        t(
          'activities.user.user_invited.others',
          owner_email: log_data.owner_email,
          role: parameters.role,
          recipient_email: log_data.recipient_email
        )
      when :profile_updated
        t(
          'activities.user.profile_updated.others',
          owner_email: log_data.owner_email,
          recipient_email: log_data.recipient_email
        )
      when :profile_deleted
        t(
          'activities.user.profile_deleted.others',
          owner_email: log_data.owner_email,
          recipient_email: log_data.recipient_email
        )
      when :role_updated
        t(
          'activities.user.role_updated.others',
          owner_email: log_data.owner_email,
          recipient_email: log_data.recipient_email,
          role: parameters.role,
          previous_role: parameters.previous_role
        )
      end
    end
  end
end
