# frozen_string_literal: true

module Mutations
  class UploadAvatar < BaseMutation
    argument :avatar, ApolloUploadServer::Upload, required: false

    field :user, Types::UserType, null: true

    def resolve(avatar:)
      resolver = ::Users::AvatarUploader.new(current_user: current_user, attributes: { avatar: avatar })
      resolver.call

      { user: current_user }
    end
  end
end
