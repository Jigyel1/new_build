# frozen_string_literal: true

require 'devise/strategies/database_authenticatable'
require 'faraday'

module Devise
  module Strategies
    class AzureAuthenticatable < DatabaseAuthenticatable
      class InvalidToken < StandardError; end

      def valid?
        true
      end

      def authenticate!
        response = mount_request.call
        resource = mapping.to.find_by!(email: response.mail)
        success!(resource)
      rescue InvalidToken => e
        fail!(e)
      rescue ActiveRecord::RecordNotFound
        fail!(I18n.t('devise.sign_in.not_found'))
      end

      private

      def mount_request # rubocop:disable Metrics/AbcSize
        header = { Authorization: request.headers['Authorization'] }

        lambda do
          Faraday.get(Rails.application.config.microsoft_graph_api, {}, header).then do |response|
            case response.status
            when 200
              OpenStruct.new(JSON(response.body))
            else
              error = JSON(response.body)['error']
              raise InvalidToken, "#{error['code']}: #{error['message']}"
            end
          end
        end
      end
    end
  end
end

Warden::Strategies.add(:azure_authenticatable, Devise::Strategies::AzureAuthenticatable)
