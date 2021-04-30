# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::RolesResolver do
  let_it_be(:administrator) { create(:role, :administrator) }
  let_it_be(:management) { create(:role, :management) }

  let_it_be(:admin_manager) { create(:user, :administrator, role: administrator, with_permissions: { role: [:read] }) }

  describe '.resolve' do
    it 'returns all roles' do
      roles, errors = paginated_collection(:roles, query, current_user: admin_manager)
      expect(errors).to be_nil
      expect(roles.pluck(:id)).to match_array(Role.pluck(:id))
      expect(roles.pluck(:name)).to match_array(Role.pluck(:name))
    end

    it 'returns users for by roles' do
      roles, errors = paginated_collection(:roles, query, current_user: admin_manager)
      expect(errors).to be_nil
      admins = roles.detect { |role| role[:id] == administrator.id }
      expect(admins[:users].pluck(:name)).to include(admin_manager.name)
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
