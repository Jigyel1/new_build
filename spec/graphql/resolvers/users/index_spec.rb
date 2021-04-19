# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Users, '#index' do
  let_it_be(:profile1) { { salutation: :mr, firstname: 'tevor', lastname: 'noah', phone: '0978887272' } }
  let_it_be(:profile2) { { salutation: :mr, firstname: 'jimmy', lastname: 'fallon', phone: '0978887273' } }
  let_it_be(:profile3) { { salutation: :mr, firstname: 'jimmy', lastname: 'kimmel', phone: '0979887272' } }
  let_it_be(:profile4) do
    {
      salutation: :mr, firstname: 'matt', lastname: 'damon', phone: '0979887273', department: :presales
    }
  end

  let_it_be(:team_expert) { create(:user, :team_expert, profile_attributes: profile1) }
  let_it_be(:team_standard) { create(:user, :team_standard, profile_attributes: profile2) }
  let_it_be(:kam) { create(:user, :kam, :inactive, profile_attributes: profile3) }
  let_it_be(:presales) { create(:user, :presales, :inactive, profile_attributes: profile4) }

  # this user won't be listed
  let_it_be(:management) { create(:user, :management, :discarded, profile_attributes: profile4) }

  describe '.resolve' do
    context 'without filters' do
      it 'returns all users sorted by name' do
        users = as_collection(:users, query)
        expect(users.pluck(:id)).to eq([team_standard.id, kam.id, presales.id, team_expert.id])
      end
    end

    context 'with role filters' do
      it 'returns users matching the given roles' do
        users = as_collection(:users, query(roles: role_names(%w[team_expert team_standard])))
        expect(users.pluck(:id)).to match_array([team_expert.id, team_standard.id])
      end
    end

    context 'with status filter' do
      it 'returns users matching the given status' do
        users = as_collection(:users, query(active: false, name: true))
        expect(users.pluck(:id)).to match_array([kam.id, presales.id])
      end
    end

    context 'with search resolvers' do
      it 'returns users matching query' do
        users = as_collection(:users, query(query: 'jimmy'))
        expect(users.pluck(:id)).to match_array([team_standard.id, kam.id])
      end

      it 'returns users matching query and filter' do
        users = as_collection(:users, query(active: true, query: 'selise.ch'))
        expect(users.pluck(:id)).to match_array([team_expert.id, team_standard.id])
      end
    end

    describe 'pagination' do
      context 'with first N filter' do
        it 'returns the first N users' do
          users = as_collection(:users, query(first: 3))
          expect(users.pluck(:id)).to eq([team_standard.id, kam.id, presales.id])
        end
      end

      context 'with skip N filter' do
        it 'returns users after skipping N records' do
          users = as_collection(:users, query(skip: 2))
          expect(users.pluck(:id)).to eq([presales.id, team_expert.id])
        end
      end

      context 'with first N & skip M filter' do
        it 'returns first N users after skipping M records' do
          users = as_collection(:users, query(first: 1, skip: 2))
          expect(users.pluck(:id)).to eq([presales.id])
        end
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        users#{query_string(args)} {
          totalCount
          edges {
            node { id email name phone role }
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

  def query_string(args = {}) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/AbcSize
    params = args[:roles] ? ["roles: #{args[:roles]}"] : []
    params << "departments: #{args[:departments]}" if args[:departments].present?
    params << "active: #{args[:active]}" unless args[:active].nil?
    params << "query: \"#{args[:query]}\"" if args[:query]
    params << "first: #{args[:first]}" if args[:first]
    params << "skip: #{args[:skip]}" if args[:skip]

    params.empty? ? nil : "(#{params.join(',')})"
  end
end
