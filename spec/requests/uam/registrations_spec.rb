# frozen_string_literal: true

require 'swagger_helper'

describe 'Registrations API', type: :request do
  path '/api/v1/users' do
    post 'Creates a new user' do
      tags 'Registration'
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

      response '200', 'user registered' do
        let(:params) { { user: { email: 'ym@selise.ch', password: 'Selise21!' } } }

        run_test! do
          expect(json).to have_attributes(email: 'ym@selise.ch')
        end
      end

      response '422', 'unprocessable entity' do
        let(:params) { { user: { password: 'Selise21' } } }
        run_test! do
          expect(json.errors).to eq(["Email #{t('errors.messages.blank')}"])
        end
      end
    end
  end
end
