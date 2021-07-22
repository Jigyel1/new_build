# frozen_string_literal: true

module ActivitiesSpecHelper
  def create_activities # rubocop:disable Metrics/SeliseMethodLength, Metrics/AbcSize
    log_data = {
      owner_email: super_user.email,
      recipient_email: administrator.email,
      parameters: { role: :administrator }
    }
    create(
      :activity,
      :yesterday,
      owner: super_user,
      recipient: administrator,
      trackable: administrator,
      action: :user_invited,
      log_data: log_data
    )

    log_data = { owner_email: super_user.email, recipient_email: management.email, parameters: { active: false } }
    create(:activity, owner: super_user, recipient: management, trackable: management, action: :status_updated, log_data: log_data)

    log_data = { owner_email: super_user.email, recipient_email: management.email }
    create(:activity, owner: super_user, recipient: management, trackable: management, action: :profile_deleted, log_data: log_data)

    log_data = {
      owner_email: super_user.email,
      recipient_email: kam.email,
      parameters: { role: :super_user, previous_role: :kam }
    }
    create(:activity, owner: super_user, recipient: kam, trackable: kam, action: :role_updated, log_data: log_data)

    log_data = { owner_email: super_user.email, recipient_email: kam.email }
    create(:activity, :tomorrow, owner: super_user, recipient: kam, trackable: kam, action: :profile_updated, log_data: log_data)
  end
end
