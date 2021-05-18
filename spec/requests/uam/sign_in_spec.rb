# frozen_string_literal: true

require 'swagger_helper'

describe 'Sign In API', type: :request do
  let_it_be(:role) { create(:role) }

  path '/api/v1/users/sign_in' do
    post 'Signs in user' do
      tags 'Login'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer Token'

      response '200', 'user signed in' do
        before do # rubocop:disable RSpec/ScatteredSetup
          stub_microsoft_graph_api_success
          create(:user, email: 'ym@selise.ch', role: role)
        end

        let(:Authorization) { SecureRandom.urlsafe_base64 }

        run_test! do
          expect(json).to have_attributes(email: 'ym@selise.ch')
        end
      end

      response '401', 'unauthorized' do
        before do # rubocop:disable RSpec/ScatteredSetup
          stub_microsoft_graph_api_unauthorized
          create(:user, email: 'ym@selise.ch', role: role)
        end

        let(:Authorization) { SecureRandom.urlsafe_base64 }

        run_test!
      end

      response '403', 'forbidden' do
        before do # rubocop:disable RSpec/ScatteredSetup
          stub_microsoft_graph_api_success
          create(:user, email: 'yma@selise.ch', role: role)
        end

        let(:Authorization) { SecureRandom.urlsafe_base64 }

        run_test!
      end
    end
  end
end
