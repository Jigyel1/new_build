module ActiveStorageAttachmentExtension
  extend ActiveSupport::Concern

  included do
    after_save :update_files_count
  end

  # `files_count` is available only for Projects & Buildings.
  def update_files_count
    return unless [Project, Projects::Building].include?(record.class)

    record = record_type.constantize.find(record_id)
    record.update_column(:files_count, record.files.size)
  end
end
