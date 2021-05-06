# frozen_string_literal: true

module ActivitiesFormatter
  class ForRecipient < BaseService
    include ActivityHelper

    def call # rubocop:disable Metrics/AbcSize, Metrics/SeliseMethodLength
      case activity.verb.to_sym
      when :status_updated
        t(
          "activities.#{activity.trackable_type.downcase}.status_updated.recipient",
          owner_email: log_data.owner_email,
          active: parameters.active
        )
      when :invited
        t(
          "activities.#{activity.trackable_type.downcase}.invited.recipient",
          owner_email: log_data.owner_email
        )
      when :profile_updated
        t(
          "activities.#{activity.trackable_type.downcase}.profile_updated.recipient",
          owner_email: log_data.owner_email
        )
      when :profile_deleted
        t(
          "activities.#{activity.trackable_type.downcase}.profile_deleted.recipient",
          owner_email: log_data.owner_email
        )
      when :role_updated
        t(
          "activities.#{activity.trackable_type.downcase}.role_updated.recipient",
          owner_email: log_data.owner_email,
          role: parameters.role
        )
      end
    end
  end
end
