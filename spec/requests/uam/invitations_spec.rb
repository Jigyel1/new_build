# frozen_string_literal: true

require 'swagger_helper'

describe 'Invitations API', type: :request do
  let_it_be(:role) { create(:role) }
  let_it_be(:user) { create(:user, role: role) }

  path '/api/v1/users/invitation' do
    post 'Sends invitation' do
      tags 'Invitation'
      consumes 'application/json'
      produces 'application/json'
      security [Bearer: []]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              email: { type: :string, default: 'ym@selise.ch' },
              role_id: { type: :integer, default: 1 },
              profile_attributes: {
                type: :object,
                properties: {
                  salutation: { type: :string, default: 'Mr' },
                  firstname: { type: :string, default: 'Yogesh' },
                  lastname: { type: :string, default: 'Mongar' },
                  phone: { type: :string, default: '+97517858728' },
                  department: { type: :string, default: 'Sales' }
                },
                required: %w[salutation firstname lastname phone]
              },
              address_attributes: {
                type: :object,
                properties: {
                  street: { type: :string, default: 'Haldenstrasse' },
                  street_no: { type: :string, default: '23' },
                  zip: { type: :string, default: '8006' },
                  city: { type: :string, default: 'Zurich' }
                },
                required: %w[street street_no zip city]
              }
            },
            required: %w[email role_id]
          }
        }
      }

      parameter name: 'Authorization', in: :header, type: :string, required: true, description: 'Bearer Token'

      response '200', 'user invited' do
        context 'without address' do
          let(:params) do
            {
              user: {
                email: 'ym@selise.ch',
                role_id: role.id,
                profile_attributes: {
                  salutation: 'Mr',
                  firstname: 'yogesh',
                  lastname: 'mongar',
                  phone: '+98717857882'
                }
              }
            }
          end
          let(:Authorization) { token(user) }

          run_test! do
            expect(json).to have_attributes(email: 'ym@selise.ch')
            expect do
              User.find_by!(email: 'ym@selise.ch')
            end.not_to raise_error

            perform_enqueued_jobs
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            mail = ActionMailer::Base.deliveries.first
            expect(mail.subject).to eq(t('devise.mailer.invitation_instructions.subject'))

            user = User.includes(:profile).find_by!(email: 'ym@selise.ch')
            expect(user.role_id).to eq(role.id)
            expect(user.profile).to(
              have_attributes(
                firstname: 'yogesh',
                lastname: 'mongar',
                salutation: 'mr',
                phone: '8717857882'
              )
            )
          end
        end

        context 'with address' do
          let(:params) do
            {
              user: {
                email: 'ym@selise.ch',
                role_id: role.id,
                profile_attributes: {
                  salutation: 'Mr',
                  firstname: 'yogesh',
                  lastname: 'mongar',
                  phone: '+98717857882'
                },
                address_attributes: {
                  street: 'haldenstrasse',
                  street_no: '23',
                  city: 'zurich',
                  zip: '8006'
                }
              }
            }
          end
          let(:Authorization) { token(user) }

          run_test! do
            user = User.includes(:profile).find_by!(email: 'ym@selise.ch')
            expect(user.address).to(
              have_attributes(
                street: 'haldenstrasse',
                street_no: '23',
                city: 'zurich',
                zip: '8006'
              )
            )
          end
        end
      end

      response '422', 'unprocessable entity' do
        let(:params) { { user: { email: 'invalid-email.ch' } } }
        let(:Authorization) { token(user) }

        run_test! do
          expect do
            Telco::Uam::User.find_by!(email: 'invalid-email.ch')
          end.to raise_error(ActiveRecord::RecordNotFound)

          expect(json.errors).to(
            eq([
                 "Email #{t('errors.messages.invalid')}",
                 "Role #{t('errors.messages.required')}",
                 "Profile #{t('errors.messages.blank')}"
               ])
          )
        end
      end

      response '400', 'bad request' do
        context 'when domain is invalid' do
          let(:params) do
            {
              user: {
                email: 'ym@invalid-domain.com',
                role_id: role.id,
                profile_attributes: {
                  salutation: 'Mr',
                  firstname: 'yogesh',
                  lastname: 'mongar',
                  phone: '+98717857882'
                }
              }
            }
          end
          let(:Authorization) { token(user) }

          run_test! do
            expect(json.errors).to(eq([Users::UserInviter::UnPermittedDomainError.new.to_s]))
          end
        end
      end
    end

    put 'Accept invitation' do
      tags 'Invitation'
      consumes 'application/json'
      produces 'application/json'

      before do
        allow_any_instance_of(Users::UserInviter).to receive(:current_user).and_return(user) # rubocop:disable RSpec/AnyInstance
        user.invite!(user)
      end

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          user: {
            type: :object,
            properties: {
              password: { type: :string, default: 'MySecurePass21!' },
              password_confirmation: { type: :string, default: 'MySecurePass21!' },
              invitation_token: { type: :string, default: 'JdtMBzQz9kYQEiszxzb3' }
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
        context 'when the token is invalid' do
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

        context 'with password mismatch' do
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

        context 'with a blank password' do
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

        context 'with a weak password' do
          let(:params) do
            {
              user: {
                password: 'weak',
                invitation_token: user.raw_invitation_token
              }
            }
          end

          run_test! do
            expect(json.errors).to eq(["Password #{t('errors.messages.too_short.other', count: 6)}"])
          end
        end
      end
    end
  end
end
