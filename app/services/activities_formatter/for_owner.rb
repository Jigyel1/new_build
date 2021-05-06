# frozen_string_literal: true

module ActivitiesFormatter
  class ForOwner < BaseService
    include ActivityHelper

    def call # rubocop:disable Metrics/AbcSize, Metrics/SeliseMethodLength
      case activity.verb.to_sym
      when :status_updated
        t(
          "activities.#{activity.trackable_type.downcase}.status_updated.owner",
          recipient_email: log_data.recipient_email,
          active: parameters.active
        )
      when :invited
        t(
          "activities.#{activity.trackable_type.downcase}.invited.owner",
          recipient_email: log_data.recipient_email
        )
      when :profile_updated
        t(
          "activities.#{activity.trackable_type.downcase}.profile_updated.owner",
          recipient_email: log_data.recipient_email
        )
      when :profile_deleted
        t(
          "activities.#{activity.trackable_type.downcase}.profile_deleted.owner",
          recipient_email: log_data.recipient_email
        )
      when :role_updated
        t(
          "activities.#{activity.trackable_type.downcase}.role_updated.owner",
          recipient_email: log_data.recipient_email,
          role: parameters.role
        )
      end
    end
  end
end
