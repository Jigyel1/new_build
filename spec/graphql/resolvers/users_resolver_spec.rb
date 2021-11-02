# frozen_string_literal: true

require 'rails_helper'
require_relative '../../support/ips_helper'

RSpec.describe Resolvers::UsersResolver do
  include IpsHelper

  let_it_be(:profile_a) { { salutation: :mr, firstname: 'tevor', lastname: 'noah', phone: '0978887272' } }
  let_it_be(:profile_b) { { salutation: :mr, firstname: 'jimmy', lastname: 'fallon', phone: '0978887273' } }
  let_it_be(:profile_c) { { salutation: :mr, firstname: 'jimmy', lastname: 'kimmel', phone: '0979887272' } }
  let_it_be(:profile_d) do
    {
      salutation: :mr, firstname: 'matt', lastname: 'damon', phone: '0979887273', department: :presales
    }
  end

  let_it_be(:super_user) do
    create(:user, :super_user, profile_attributes: profile_a, with_permissions: { user: :read })
  end
  let_it_be(:team_standard) { create(:user, :team_standard, profile_attributes: profile_b) }
  let_it_be(:kam) { create(:user, :kam, :inactive, profile_attributes: profile_c) }
  let_it_be(:presales) { create(:user, :presales, :inactive, profile_attributes: profile_d) }

  # this user won't be listed
  let_it_be(:management) { create(:user, :management, :discarded, profile_attributes: profile_d) }

  describe '.resolve' do
    context 'without filters' do
      it 'returns all users sorted by name' do
        users, errors = paginated_collection(:users, query, current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to eq([team_standard.id, kam.id, presales.id, super_user.id])
      end
    end

    context 'with role filters' do
      it 'returns users matching the given roles' do
        users, errors = paginated_collection(
          :users,
          query(role_ids: role_ids(%w[super_user team_standard])),
          current_user: super_user
        )
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([super_user.id, team_standard.id])
      end
    end

    context 'with status filter' do
      it 'returns users matching the given status' do
        users, errors = paginated_collection(:users, query(active: false), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([kam.id, presales.id])
      end
    end

    context 'with department filters' do
      it 'returns users matching the given departments' do
        users, errors = paginated_collection(:users, query(departments: %w[presales]), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to eq([presales.id])
      end
    end

    context 'with search resolvers' do
      it 'returns users matching query' do
        users, errors = paginated_collection(:users, query(query: 'jimmy'), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([team_standard.id, kam.id])
      end

      it 'returns users matching query and filter' do
        users, errors = paginated_collection(:users, query(active: true, query: 'selise.ch'), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([super_user.id, team_standard.id])
      end
    end

    describe 'pagination' do
      context 'with first N filter' do
        it 'returns the first N users' do
          users, errors = paginated_collection(:users, query(first: 3), current_user: super_user)
          expect(errors).to be_nil
          expect(users.pluck(:id)).to eq([team_standard.id, kam.id, presales.id])
        end
      end

      context 'with skip N filter' do
        it 'returns users after skipping N records' do
          users, errors = paginated_collection(:users, query(skip: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(users.pluck(:id)).to eq([presales.id, super_user.id])
        end
      end

      context 'with first N & skip M filter' do
        it 'returns first N users after skipping M records' do
          users, errors = paginated_collection(:users, query(first: 1, skip: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(users.pluck(:id)).to eq([presales.id])
        end
      end
    end

    describe 'performance benchmarks' do
      it 'executes within 30 ms' do
        expect { paginated_collection(:users, query, current_user: super_user) }.to perform_under(30).ms
      end

      it 'executes n iterations in x seconds', ips: true do
        expect { paginated_collection(:users, query, current_user: super_user) }.to(
          perform_at_least(perform_atleast).within(perform_within).warmup(warmup_for).ips
        )
      end
    end
  end

  def query(args = {})
    connection_query("users#{query_string(args)}", 'id email name phone role department')
  end
end
