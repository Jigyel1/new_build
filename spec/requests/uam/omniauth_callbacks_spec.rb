# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/omniauth_test_helper'

describe 'GET api/v1/users/auth/azure_activedirectory_v2/callback' do # rubocop:disable RSpec/MultipleDescribes
  include OmniauthTestHelper

  before do
    valid_azure_login_setup
    Rails.application.env_config['devise.mapping'] = Devise.mappings[:user] # If using Devise
    Rails.application.env_config['omniauth.auth'] = OmniAuth.config.mock_auth[:azure_activedirectory_v2] # rubocop:disable Naming/VariableNumber
  end

  context 'for a valid user' do
    let_it_be(:super_user) { create(:user, :super_user, email: 'ym@selise.ch') }
    before do
      get user_azure_activedirectory_v2_omniauth_callback_path, params: { redirect_uri: '/api/v1/omniauth/azure_ad' }
    end

    it 'sets user_id' do
      expect(session['warden.user.user.key'][0][0]).to eq(super_user.id)
    end
  end

  context 'when user does not exist in the portal' do
    before do
      get user_azure_activedirectory_v2_omniauth_callback_path
    end

    it 'raises user not invited exception' do
      expect(session['warden.user.user.key']).to be_nil
      expect(response).to have_http_status(:redirect)
      expect(response.body).to include("#{root_url}auth/login-failed")
    end
  end
end

describe "GET '/api/v1/users/auth/failure'" do
  after { Rails.application.reload_routes! }

  before do
    Rails.application.routes.draw do
      devise_scope :user do
        get 'api/v1/omniauth_callbacks/failure' => 'telco/uam/api/v1/omniauth_callbacks#failure'
      end
    end
  end

  it 'raises bad request' do
    get '/api/v1/omniauth_callbacks/failure'
    expect(response).to have_http_status(:bad_request)
  end
end
