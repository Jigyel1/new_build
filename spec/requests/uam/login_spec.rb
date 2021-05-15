# frozen_string_literal: true

require 'swagger_helper'

describe 'Login API', type: :request do
  let_it_be(:role) { create(:role) }

  path '/api/v1/users/sign_in' do
    post 'Signs in user' do
      tags 'Login'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer Token'

      response '200', 'user signed in' do
        before { stub_microsoft_graph_api_success }

        let_it_be(:user) { create(:user, email: 'ym@selise.ch', role: role) }

        let(:Authorization) { SecureRandom.urlsafe_base64 }

        run_test! do
          expect(json).to have_attributes(email: 'ym@selise.ch')
        end
      end

      response '401', 'unauthorized' do
        context 'when token is invalid' do
          before { stub_microsoft_graph_api_unauthorized }

          let_it_be(:user) { create(:user, email: 'ym@selise.ch', role: role) }
          let(:Authorization) { SecureRandom.urlsafe_base64 }

          run_test!
        end

        context 'when user does not exist in the portal' do
          before { stub_microsoft_graph_api_success }

          let_it_be(:user) { create(:user, email: 'yma@selise.ch', role: role) }
          let(:Authorization) { SecureRandom.urlsafe_base64 }

          run_test!
        end
      end
    end
  end
end
