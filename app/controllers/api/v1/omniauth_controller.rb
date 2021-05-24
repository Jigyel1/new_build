module Api
  module V1
    class OmniauthController < ActionController::API
      def authorization_endpoint
        render json: { endpoint: "#{endpoint}?#{URI.encode_www_form(params)}" }, status: :unauthorized
      end

      private

      def endpoint
        api_v1_user_azure_activedirectory_v2_omniauth_authorize_path
      end

      def params
        {
          client_id: Rails.application.config.azure_client_id,
          tenant_id: Rails.application.config.azure_tenant_id
        }
      end
    end
  end
end
