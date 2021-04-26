# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Role, '#show' do
  let_it_be(:team_expert) { create(:user, :team_expert) }
  let_it_be(:user_role) { team_expert.role }

  describe '.resolve' do
      it 'returns current user details' do
        role, errors = formatted_response(query(id: user_role.id), current_user: team_expert, key: :role)
        expect(errors).to be_nil
        expect(role).to have_attributes(
          id: role.id,
          name: role.name
        )
    end

    context "when record doesn't exist" do
      it 'responds with error' do
        response, errors = formatted_response(
          query(id: '16c85b18-473d-4f5d-9ab4-666c7faceb6c\"'), current_user: team_expert
        )

        expect(response.role).to be_nil
        expect(errors[0]).to include("Couldn't find Role with 'id'=16c85b18-473d-4f5d-9ab4-666c7faceb6c\"")
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        role#{query_string(args)} {
          id
          name
        }
      }
    GQL
  end

  def query_string(args = {})
    args[:id].present? ? "(id: \"#{args[:id]}\")" : nil
  end
end
