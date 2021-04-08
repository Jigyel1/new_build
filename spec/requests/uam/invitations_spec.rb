# frozen_string_literal: true

require 'swagger_helper'

describe 'Invitations API', type: :request do
  path '/api/v1/users/invitation' do
    post 'Sends invitation' do
      tags 'Invitation'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      let!(:user) { create(:user) }

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

      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer Token'

      response '200', 'user invited' do
        let(:params) { { user: { email: 'ym@selise.ch' } } }
        let(:Authorization) { token(user) }

        run_test! do
          expect(json).to have_attributes(email: 'ym@selise.ch')
          expect do
            Telco::Uam::User.find_by!(email: 'ym@selise.ch')
          end.not_to raise_error

          expect(ActionMailer::Base.deliveries.count).to eq(1)
          mail = ActionMailer::Base.deliveries.first
          expect(mail.subject).to eq(t('devise.mailer.invitation_instructions.subject'))
        end
      end

      response '422', 'unprocessable entity' do
        let(:params) { { user: { email: 'invalid-email.ch' } } }
        let(:Authorization) { token(user) }

        run_test! do
          expect do
            Telco::Uam::User.find_by!(email: 'invalid-email.ch')
          end.to raise_error(ActiveRecord::RecordNotFound)

          expect(json.errors).to eq(["Email #{t('errors.messages.invalid')}"])
        end
      end
    end

    put 'Accept invitation' do
      tags 'Invitation'
      consumes 'application/json'
      produces 'application/json'

      let!(:user) { create(:user) }
      before { user.invite! }

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              password: { type: :string, required: true },
              password_confirmation: { type: :string },
              invitation_token: { type: :string, required: true }
            },
            required: %w[password invitation_token]
          }
        }
      }

      response '200', 'invitation accepted' do
        let(:params) do
          {
            user: {
              password: 'Selise99',
              invitation_token: user.raw_invitation_token
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
                invitation_token: 'some-invalid-token'
              }
            }
          end

          run_test! do
            expect(json.errors).to eq(["Invitation token #{t('errors.messages.invalid')}"])
          end
        end

        context 'password mismatch' do
          let(:params) do
            {
              user: {
                password: 'Selise99',
                password_confirmation: 'Selise29',
                invitation_token: user.raw_invitation_token
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
                invitation_token: user.raw_invitation_token
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
                invitation_token: user.raw_invitation_token
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
