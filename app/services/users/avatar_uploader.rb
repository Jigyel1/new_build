# frozen_string_literal: true

module Users
  class AvatarUploader < BaseService
    def call
      current_user.profile.update!(
        avatar_url: Cnc::Storage.by_request(attributes[:avatar]).first.to_s
      )
    end
  end
end
