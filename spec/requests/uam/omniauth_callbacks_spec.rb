require 'rails_helper'
require_relative '../../support/omniauth_test_helper'

describe "GET api/v1/users/auth/azure_activedirectory_v2/callback" do
  include OmniauthTestHelper

  before do
    allow_any_instance_of(
      Api::V1::OmniauthCallbacksController
    ).to(
      receive(:omniauth_params).and_return(
        'state' => '/api/v1/omniauth/azure_ad'
      )
    )

    valid_azure_login_setup
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user] # If using Devise
    Rails.application.env_config["omniauth.auth"] = OmniAuth.config.mock_auth[:azure_activedirectory_v2]
  end

  context 'for a valid user' do
    let_it_be(:super_user) { create(:user, :super_user, email: 'ym@selise.ch') }
    before do
      get api_v1_user_azure_activedirectory_v2_omniauth_callback_path
    end

    it "sets user_id" do
      expect(session["warden.user.api_v1_user.key"][0][0]).to eq(super_user.id)
    end

    it "redirects to the path given as a state" do
      expect(response).to redirect_to "#{root_url}api/v1/omniauth/azure_ad"
    end
  end

  context 'when user does not exist in the portal' do
    before do
      get api_v1_user_azure_activedirectory_v2_omniauth_callback_path
    end

    it 'raises user not invited exception' do
      expect(session["warden.user.api_v1_user.key"]).to be_nil
      expect(response).to have_http_status(:forbidden)
      expect(json.errors).to eq([t('devise.sign_in.not_found')])
    end
  end
end

describe "GET '/auth/failure'" do
  after do
    Rails.application.reload_routes!
  end

  before do

    Rails.application.routes.draw do
      devise_scope :user do
        get 'api/v1/omniauth_callbacks/failure' => 'telco/uam/api/v1/omniauth_callbacks#failure'
      end
    end
  end

  it "raises bad request" do
    get '/api/v1/omniauth_callbacks/failure'
    expect(response).to have_http_status(:bad_request)
  end
end