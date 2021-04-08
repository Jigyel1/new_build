# frozen_string_literal: true

require 'swagger_helper'

describe 'Sessions API', type: :request do
  path '/api/v1/users/sign_in' do
    post 'Creates a user session' do
      tags 'Login'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string },
              password: { type: :string }
            },
            required: %w[email password]
          }
        }
      }

      let_it_be(:current_user) { create(:user, email: 'ym@selise.ch', password: 'Selise21!') }

      response '200', 'success' do
        let(:params) { { user: { email: 'ym@selise.ch', password: 'Selise21!' } } }

        run_test! do
          expect(json).to have_attributes(email: 'ym@selise.ch', id: current_user.id)
        end
      end

      response '401', 'unauthorized' do
        let(:params) { { email: 'ym@selise.ch', password: 'Invalid Password!' } }
        run_test!
      end
    end
  end
end
