# Api::V1::OmniauthCallbacksController = Telco::Uam::Api::V1::OmniauthCallbacksController

module Api
  module V1
    class OmniauthController < ActionController::Base

      def authorization_endpoint
        session['omniauth.state'] = omniauth_state
        session['redirect_uri'] = params['redirect_uri']
        redirect_to "#{endpoint}?#{URI.encode_www_form(request_params)}"
      end

      private

      def endpoint
        'https://login.microsoftonline.com/5c6dd6a7-f0c7-4a32-8f7c-9ca7cebf6e87/oauth2/v2.0/authorize'
      end

      def request_params
        {
          state: omniauth_state,
          response_type: :code,
          client_id: Rails.application.config.azure_client_id,
          tenant_id: Rails.application.config.azure_tenant_id,
          scope: 'User.read',
          redirect_uri: "#{request.base_url}/api/v1/users/auth/azure_activedirectory_v2/callback"
        }
      end

      def omniauth_state
        @omniauth_state ||= SecureRandom.hex(24)
      end
    end
  end
end
