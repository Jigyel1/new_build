# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::DeleteUser do
  let_it_be(:team_expert) { create(:user, :team_expert) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    it 'deletes the user' do
      response, errors = formatted_response(query(id: team_standard.id), current_user: team_expert, key: :deleteUser)
      expect(errors).to be_nil
      expect(response.status).to be(true)

      expect { User.find(team_standard.id) }.to raise_error(ActiveRecord::RecordNotFound)
      expect { User.unscoped.find(team_standard.id) }.not_to raise_error
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
