# frozen_string_literal: true

class Activity < ApplicationRecord
  include JsonAccessible

  belongs_to :owner, class_name: 'Telco::Uam::User'

  # `recipient` is not needed when a user is acting on a different module.
  # eg. User(owner) updates PCT(trackable)
  #
  # `trackable` is not needed when a user is acting on another user.
  # eg. User A(owner) deactivates User B(recipient)
  #
  # A case where all references will be applicable
  # eg. User A(owner) added User B(recipient) to Project X(trackable)
  #
  belongs_to :recipient, class_name: 'Telco::Uam::User', optional: true
  belongs_to :trackable, polymorphic: true, optional: true

  alias actor owner
  alias object recipient
  alias target trackable

  validates(
    :action,
    presence: true,
    inclusion: {
      in: proc { |activity| Rails.application.config.activity_actions[activity.trackable_type.downcase] },
      if: proc { |activity| activity.trackable_type.present? }
    }
  )

  validates :log_data, activity_log: true

  # Although trackable is optional(for users at least, the trackable type is still
  # set as `User`. This is necessary when rendering the activity)
  validates :trackable_type, presence: true

  default_scope { order(created_at: :desc) }
end
