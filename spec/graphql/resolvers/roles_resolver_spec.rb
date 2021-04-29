# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::RolesResolver do
  let_it_be(:team_expert) { create(:role, :team_expert) }
  let_it_be(:team_standard) { create(:role, :team_standard) }
  let_it_be(:management) { create(:role, :management) }

  let_it_be(:manager) { create(:user, :super_user, role: management) }

  describe '.resolve' do
    it 'returns all roles' do
      roles, errors = as_collection(:roles, query)
      expect(errors).to be_nil
      expect(roles.pluck(:id)).to match_array(Role.pluck(:id))
      expect(roles.pluck(:name)).to match_array(Role.pluck(:name))
    end

    it 'returns users for by roles' do
      roles, errors = as_collection(:roles, query)
      expect(errors).to be_nil
      managers = roles.detect { |role| role[:id] == management.id }
      expect(managers[:users].pluck(:name)).to include(manager.name)
    end
  end

  def query
    <<~GQL
      query {
        roles {
          totalCount
          edges {
            node { id name users { name avatarUrl } }
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
