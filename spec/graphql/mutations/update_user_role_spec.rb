# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateUserRole do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:update_role] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    context 'with valid permissions' do
      let!(:params) { { id: team_standard.id, role_id: super_user.role_id } }

      it 'updates the user role' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateUserRole)
        expect(errors).to be_nil
        expect(response.user.roleId).to eq(super_user.role_id)
      end
    end

    context 'when updating your own role' do
      let!(:params) { { id: super_user.id, role_id: team_standard.role_id } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateUserRole)
        expect(response.user).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateUserRole(
          input: {
            attributes: {
              id: "#{args[:id]}"
              roleId: "#{args[:role_id]}"
            }
          }
        )
        { user { id roleId } }
      }
    GQL
  end
end
