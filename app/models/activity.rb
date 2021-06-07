# frozen_string_literal: true

class Activity < ApplicationRecord
  include JsonAccessible

  belongs_to :owner, class_name: 'Telco::Uam::User'
  belongs_to :recipient, class_name: 'Telco::Uam::User'

  # `optional true` when the activity involves just the users. `trackable` will
  # come into picture when we use other modules like project, news, events etc.
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
