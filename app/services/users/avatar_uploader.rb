# frozen_string_literal: true

module Users
  class AvatarUploader < BaseService
    def call
      avatar.attach(blob)
      avatar.save!

      profile.update_column(:avatar_url, rails_blob_path(current_user.profile.avatar))
    end

    private

    def profile
      @profile ||= current_user.profile
    end

    def avatar
      @avatar ||= profile.avatar
    end

    def blob
      file = attributes[:avatar]
      @blob ||= ActiveStorage::Blob.create_and_upload!(
        io: file,
        filename: file.original_filename,
        content_type: file.content_type
      )
    end
  end
end
