# frozen_string_literal: true

require 'rails_helper'

describe Mutations::UploadAvatar, type: :request do
  let_it_be(:super_user) { create(:user, :super_user) }

  let_it_be(:params) do
    {
      operations: {
        query: query,
        variables: {
          avatar: nil
        }
      }.to_json,
      map: { avatar: ['variables.avatar'] }.to_json,
      avatar: file_upload
    }
  end

  before do
    sign_in(super_user)
    Bullet.enable = false
  end

  after { Bullet.enable = true }

  it 'uploads user avatar' do
    post api_v1_graphql_path, params: params

    user = json.data.uploadAvatar.user
    expect(user.profile.avatarUrl).to be_present
  end

  def query
    <<~QUERY
      mutation($avatar: Upload!) {
        uploadAvatar( input: { avatar: $avatar } ){
          user { id profile { id avatarUrl } }
        }
      }
    QUERY
  end
end
