# Api::V1::OmniauthCallbacksController = Telco::Uam::Api::V1::OmniauthCallbacksController

module Api
  module V1
    class OmniauthController < ActionController::Base
      after_action :set_csrf_token
      # before_action :form_authenticity_token

      def authorization_endpoint
        session['omniauth.state'] = omniauth_state
        session['after_login_url'] = params['url']
        # # byebug
        # render json: { endpoint: "#{endpoint}?#{URI.encode_www_form(params)}" }, status: :ok
        redirect_to "#{endpoint}?#{URI.encode_www_form(params)}"
      end



      private

      def endpoint
        'https://login.microsoftonline.com/5c6dd6a7-f0c7-4a32-8f7c-9ca7cebf6e87/oauth2/v2.0/authorize'
      end

      def params
        {
          state: omniauth_state,
          response_type: :code,
          client_id: Rails.application.config.azure_client_id,
          tenant_id: Rails.application.config.azure_tenant_id,
          scope: 'User.read',
          redirect_uri: "#{request.base_url}/api/v1/users/auth/azure_activedirectory_v2/callback"
        }
      end

      def set_csrf_token
        cookies['X-CSRF-TOKEN'] = {
          value: form_authenticity_token,
          http_only: true
        }
      end

      def omniauth_state
        @omniauth_state ||= SecureRandom.hex(24)
      end
    end
  end
end
