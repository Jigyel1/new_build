# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateUserRole do
  let_it_be(:team_expert) { create(:user, :team_expert) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    let!(:params) { { id: team_standard.id, role_id: team_expert.role_id } }

    it 'updates the user role' do
      response, errors = formatted_response(query(params), current_user: team_expert, key: :updateUserRole)
      expect(errors).to be_nil
      expect(response.user.roleId).to eq(team_expert.role_id)
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateUserRole(
          input: {
            id: "#{args[:id]}"
            roleId: "#{args[:role_id]}"
          }
        )
        { user { id roleId } }
      }
    GQL
  end
end
