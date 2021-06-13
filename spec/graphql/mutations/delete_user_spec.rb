# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteUser do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:delete] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    context 'for a valid user' do
      it 'soft deletes the user' do
        response, errors = formatted_response(query(id: team_standard.id), current_user: super_user, key: :deleteUser)
        expect(errors).to be_nil
        expect(response.status).to be(true)

        expect { User.find(team_standard.id) }.to raise_error(ActiveRecord::RecordNotFound)
        expect { User.unscoped.find(team_standard.id) }.not_to raise_error
        expect(team_standard.reload.discarded_at).to be_present
      end

      it 'resets user email with current time prefixed' do
        response, errors = formatted_response(query(id: team_standard.id), current_user: super_user, key: :deleteUser)
        expect(errors).to be_nil
        expect(response.status).to be(true)

        expect(team_standard.reload.email).to include(Time.current.strftime('%Y_%m_%d_%H_'))
      end
    end

    context 'when user does not exist in the portal' do
      it 'responds with error' do
        response, errors = formatted_response(
          query(id: '16c85b18-473d-4f5d-9ab4-666c7faceb6c\"'), current_user: super_user, key: :deleteUser
        )

        expect(response.user).to be_nil
        expect(errors[0]).to include("Couldn't find Telco::Uam::User with 'id'=16c85b18-473d-4f5d-9ab4-666c7faceb6c\"")
      end
    end

    context 'when deleting your own profile' do
      it 'forbids action' do
        response, errors = formatted_response(query(id: super_user.id), current_user: super_user, key: :deleteUser)
        expect(response.user).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        deleteUser(
          input: {
            id: "#{args[:id]}"
          }
        )
        { status }
      }
    GQL
  end
end
