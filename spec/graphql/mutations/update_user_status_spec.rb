# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateUserStatus do
  let_it_be(:team_expert) { create(:user, :team_expert) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    let!(:params) { { id: team_standard.id, active: false } }

    it 'updates the user status' do
      response, errors = formatted_response(query(params), current_user: team_expert, key: :updateUserStatus)
      expect(errors).to be_nil
      expect(response.user.active).to be(false)
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateUserStatus(
          input: {
            id: "#{args[:id]}"
            active: #{args[:active]}
          }
        )
        { user { id active } }
      }
    GQL
  end
end
