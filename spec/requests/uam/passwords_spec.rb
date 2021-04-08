# frozen_string_literal: true

require 'swagger_helper'

describe 'Password API', type: :request do
  path '/api/v1/users/password' do
    post 'Sends password reset link' do
      tags 'Password'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string }
            },
            required: %w[email]
          }
        }
      }

      response '201', 'link sent' do
        let!(:user) { create(:user) }
        let(:params) { { user: { email: user.email } } }

        run_test! do
          expect(ActionMailer::Base.deliveries.count).to eq(1)

          mail = ActionMailer::Base.deliveries.first
          expect(mail.subject).to eq(t('devise.mailer.reset_password_instructions.subject'))
        end
      end

      response '422', 'not found' do
        let(:params) { { user: { email: 'ym@selise.ch' } } }

        run_test! do
          expect(json.errors).to eq(["Email #{t('errors.messages.not_found')}"])
          expect(ActionMailer::Base.deliveries.count).to eq(0)
        end
      end
    end

    put 'Update password' do
      tags 'Password'
      consumes 'application/json'
      produces 'application/json'

      let!(:user) { create(:user) }

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              password: { type: :string, required: true },
              password_confirmation: { type: :string },
              reset_password_token: { type: :string, required: true }
            },
            required: %w[password invitation_token]
          }
        }
      }

      response '200', 'updates password' do
        let(:params) do
          {
            user: {
              password: 'Selise99',
              reset_password_token: user.send_reset_password_instructions
            }
          }
        end

        run_test!
      end

      response '422', 'unprocessable entity' do
        context 'token is invalid' do
          let(:params) do
            {
              user: {
                password: 'Selise99',
                reset_password_token: 'some-invalid-token'
              }
            }
          end

          run_test! do
            expect(json.errors).to eq(["Reset password token #{t('errors.messages.invalid')}"])
          end
        end

        context 'password mismatch' do
          let(:params) do
            {
              user: {
                password: 'Selise99',
                password_confirmation: 'Selise29',
                reset_password_token: user.send_reset_password_instructions
              }
            }
          end

          run_test! do
            expect(json.errors).to(
              eq(["Password confirmation #{t('errors.messages.confirmation', attribute: :Password)}"])
            )
          end
        end

        context 'blank password' do
          let(:params) do
            {
              user: {
                password: '',
                reset_password_token: user.send_reset_password_instructions
              }
            }
          end

          run_test! do
            expect(json.errors).to eq(["Password #{t('errors.messages.blank')}"])
          end
        end

        context 'weak password' do
          let(:params) do
            {
              user: {
                password: 'weak-pass',
                reset_password_token: user.send_reset_password_instructions
              }
            }
          end

          run_test! do
            expect(json.errors).to eq(["Password #{t('devise.passwords.weak_password')}"])
          end
        end
      end
    end
  end
end
