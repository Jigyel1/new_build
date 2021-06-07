# frozen_string_literal: true

module Api
  module V1
    class OmniauthController < ApplicationController
      # @param redirect_uri [String] where the user is redirected after a successful authentication
      def authorization_endpoint
        session['omniauth.state'] = omniauth_state
        session['redirect_uri'] = redirect_uri
        redirect_to "#{Rails.application.config.azure_authorization_endpoint}?#{URI.encode_www_form(request_params)}"
      end

      private

      def request_params
        {
          state: omniauth_state,
          response_type: :code,
          client_id: Rails.application.config.azure_client_id,
          tenant_id: Rails.application.config.azure_tenant_id,
          scope: 'User.read',
          redirect_uri: "#{request.base_url}/#{Rails.application.config.azure_callback_uri}"
        }
      end

      def omniauth_state
        @omniauth_state ||= SecureRandom.hex(24)
      end

      # Validates if the redirect happens to the same application
      # with an exception of `localhost:4200` which will only be enabled for TEST servers
      def redirect_uri
        redirect_uri = params['redirect_uri'] || super
        uri = URI.parse(redirect_uri)

        case uri.host
        when URI.parse(request.base_url).host, 'localhost' then redirect_uri
        else raise StandardError, "Invalid redirect_uri => #{redirect_uri}"
        end
      end
    end
  end
end
