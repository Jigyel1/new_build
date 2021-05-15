# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateUserStatus do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: [:update_status] }) }
  let_it_be(:team_standard) { create(:user, :team_standard) }

  describe '.resolve' do
    let!(:params) { { id: team_standard.id, active: false } }

    it 'updates the user status' do
      response, errors = formatted_response(query(params), current_user: super_user, key: :updateUserStatus)
      expect(errors).to be_nil
      expect(response.user.active).to be(false)
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateUserStatus(
          input: {
            attributes: {
              id: "#{args[:id]}"
              active: #{args[:active]}
            }
          }
        )
        { user { id active } }
      }
    GQL
  end

  def activities_query
    <<~GQL
      query {
        activities {
          totalCount
          edges {
            node {
              id createdAt displayText
            }
          }
        }
      }
    GQL
  end
end
