# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateUser do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:update] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }
  let_it_be(:address) { create(:address, addressable: team_standard) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) do
        {
          id: team_standard.id,
          profile_id: team_standard.profile.id,
          salutation: 'mr',
          firstname: 'jitender',
          lastname: 'rathore',
          address_id: address.id,
          street_no: '33'
        }
      end

      it 'updates the user' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateUser)
        expect(errors).to be_nil

        user = response.user
        expect(user.profile).to have_attributes(
          salutation: 'mr',
          firstname: 'jitender',
          lastname: 'rathore'
        )

        expect(user.address).to have_attributes(
          streetNo: '33'
        )
      end
    end

    context 'with invalid params' do
      let!(:params) do
        {
          id: team_standard.id,
          profile_id: team_standard.profile.id,
          salutation: '',
          firstname: '',
          lastname: 'rathore'
        }
      end

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateUser)
        expect(response.user).to be_nil

        expect(errors).to match_array(
          [
            [
              "Profile salutation #{t('errors.messages.blank')}",
              "Profile firstname #{t('errors.messages.blank')}"
            ].to_sentence
          ]
        )
      end
    end
  end

  def query(args = {})
    profile = <<~PROFILE
      profile: {
        id: "#{args[:profile_id]}"
        salutation: "#{args[:salutation]}"
        firstname: "#{args[:firstname]}"
        lastname: "#{args[:lastname]}"
      }
    PROFILE

    address = <<~ADDRESS
      address: {
        id: "#{args[:address_id]}"
        streetNo: "#{args[:street_no]}"
      }
    ADDRESS

    <<~GQL
      mutation {
        updateUser(
          input: {
            attributes: {
              id: "#{args[:id]}"
              #{profile if args[:profile_id]}
              #{address if args[:address_id]}
            }
          }
        )
        { user { id email profile { salutation firstname lastname } address { streetNo } } }
      }
    GQL
  end
end
