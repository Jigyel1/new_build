module Api
  module V1
    class OmniauthController < ActionController::API
      def authorization_endpoint
        render json: { endpoint: "#{endpoint}?#{URI.encode_www_form(params)}" }, status: :ok
      end

      private

      def endpoint
        'https://login.microsoftonline.com/5c6dd6a7-f0c7-4a32-8f7c-9ca7cebf6e87/oauth2/v2.0/authorize'
      end

      def params
        {
          client_id: Rails.application.config.azure_client_id,
          tenant_id: Rails.application.config.azure_tenant_id,
          redirect_uri: "#{request.base_url}/#{api_v1_user_azure_activedirectory_v2_omniauth_callback_path}"
        }
      end
    end
  end
end
