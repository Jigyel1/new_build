# frozen_string_literal: true

module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    belongs_to :owner, class_name: 'Telco::Uam::User', optional: true

    before_validation :set_owner
    after_save :update_files_count
  end

  private

  # Current.current_user won't be nil unless when run with rspec where you just execute the schema definition.
  # The safe operation is a trade-off for using the `before_all` options in the rspec as the use of mocks
  # outside of per-test lifecycle aren't supported.
  def set_owner
    self.owner_id ||= Current.current_user.try(:id)
  end

  # `files_count` is available only for Projects & Buildings.
  def update_files_count
    return if [Project, Projects::Building].exclude?(record.class)

    record = record_type.constantize.find(record_id)
    record.update_column(:files_count, record.files.size)
  end
end
