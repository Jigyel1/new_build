# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Roles, '#index' do
  let_it_be(:team_expert) { create(:role, :team_expert) }
  let_it_be(:team_standard) { create(:role, :team_standard) }
  let_it_be(:management) { create(:role, :management) }

  describe '.resolve' do
    it 'returns all roles' do
      roles = as_collection(:roles, query)
      expect(roles.pluck(:id)).to match_array(Role.pluck(:id))
      expect(roles.pluck(:name)).to match_array(Role.pluck(:name))
    end
  end

  def query
    <<~GQL
      query {
        roles {
          totalCount
          edges {
            node { id name }
          }
          pageInfo {
            endCursor
            startCursor
            hasNextPage
            hasPreviousPage
          }
        }
      }
    GQL
  end
end
