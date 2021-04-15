# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateUser do
  let_it_be(:team_expert) { create(:user, :team_expert) }
  let_it_be(:team_standard) { create(:user, :team_standard) }
  let_it_be(:address) { create(:address, addressable: team_standard) }

  describe '.resolve' do
    let!(:new_role_id) { role_id(:kam) }

    context 'with valid params' do
      let!(:params) do
        {
          id: team_standard.id,
          role_id: new_role_id,
          profile_id: team_standard.profile.id,
          salutation: 'mr',
          firstname: 'jitender',
          lastname: 'rathore',
          address_id: address.id,
          street_no: '33'
        }
      end

      it 'updates the user' do
        response, errors = formatted_response(query(params), current_user: team_expert, key: :updateUser)
        expect(errors).to be_nil

        user = response.user
        expect(user).to have_attributes(
          roleId: new_role_id.to_s
        )
        expect(user.role).to have_attributes(
          id: new_role_id.to_s,
          name: role_name(new_role_id)
        )
      end
    end

    context 'with invalid params' do
      let!(:params) do
        {
          id: team_standard.id,
          role_id: nil,
          profile_id: team_standard.profile.id,
          salutation: '',
          firstname: '',
          lastname: 'rathore'
        }
      end

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: team_expert, key: :updateUser)
        expect(response.user).to be_nil

        expect(errors).to match_array(
          [[
            "Role #{t('errors.messages.required')}",
            "Profile salutation #{t('errors.messages.blank')}",
            "Profile firstname #{t('errors.messages.blank')}"
          ].to_sentence]
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
        street_no: "#{args[:street_no]}"
      }
    ADDRESS

    <<~GQL
      mutation {
        updateUser(
          input: {
            id: "#{args[:id]}"
            roleId: "#{args[:role_id]}"
            #{profile if args[:profile_id]}
            #{address if args[:address_id]}
          }
        )
        { user { id roleId email role { id name } } } }
    GQL
  end
end
