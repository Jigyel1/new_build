# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/ips_helper'

RSpec.describe Resolvers::RolesResolver do
  include IpsHelper

  let_it_be(:administrator) { create(:role, :administrator) }
  let_it_be(:management) { create(:role, :management) }

  let_it_be(:admin_manager) { create(:user, :administrator, role: administrator, with_permissions: { role: :read }) }

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

    describe 'performance benchmarks' do
      it 'executes within 30 ms' do
        expect { paginated_collection(:roles, query, current_user: admin_manager) }.to perform_under(30).ms
      end

      it 'executes n iterations in x seconds', ips: true do
        expect { paginated_collection(:roles, query, current_user: admin_manager) }.to(
          perform_at_least(perform_atleast).within(perform_within).warmup(warmup_for).ips
        )
      end
    end
  end

  def query
    connection_query('roles', 'id name users { name avatarUrl }')
  end
end
