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

  let_it_be(:super_user) { create(:user, :super_user, profile_attributes: profile1) }
  before_all do
    create(:permission, accessor: Role.find_by(id: super_user.role_id), resource: :user, actions: { read: true })
  end

  let_it_be(:team_standard) { create(:user, :team_standard, profile_attributes: profile2) }
  let_it_be(:kam) { create(:user, :kam, :inactive, profile_attributes: profile3) }
  let_it_be(:presales) { create(:user, :presales, :inactive, profile_attributes: profile4) }

  # this user won't be listed
  let_it_be(:management) { create(:user, :management, :discarded, profile_attributes: profile4) }

  describe '.resolve' do
    context 'without filters' do
      it 'returns all users sorted by name' do
        users, errors = as_collection(:users, query, current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to eq([team_standard.id, kam.id, presales.id, super_user.id])
      end
    end

    context 'with role filters' do
      it 'returns users matching the given roles' do
        users, errors = as_collection(:users, query(roleIds: role_ids(%w[super_user team_standard])), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([super_user.id, team_standard.id])
      end
    end

    context 'with status filter' do
      it 'returns users matching the given status' do
        users, errors = as_collection(:users, query(active: false, name: true), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([kam.id, presales.id])
      end
    end

    context 'with department filters' do
      it 'returns users matching the given departments' do
        users, errors = as_collection(:users, query(departments: %w[presales]), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to eq([presales.id])
      end
    end

    context 'with search resolvers' do
      it 'returns users matching query' do
        users, errors = as_collection(:users, query(query: 'jimmy'), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([team_standard.id, kam.id])
      end

      it 'returns users matching query and filter' do
        users, errors = as_collection(:users, query(active: true, query: 'selise.ch'), current_user: super_user)
        expect(errors).to be_nil
        expect(users.pluck(:id)).to match_array([super_user.id, team_standard.id])
      end
    end

    describe 'pagination' do
      context 'with first N filter' do
        it 'returns the first N users' do
          users, errors = as_collection(:users, query(first: 3), current_user: super_user)
          expect(errors).to be_nil
          expect(users.pluck(:id)).to eq([team_standard.id, kam.id, presales.id])
        end
      end

      context 'with skip N filter' do
        it 'returns users after skipping N records' do
          users, errors = as_collection(:users, query(skip: 2), current_user: super_user)
          expect(errors).to be_nil
          expect(users.pluck(:id)).to eq([presales.id, super_user.id])
        end
      end

      context 'with first N & skip M filter' do
        it 'returns first N users after skipping M records' do
          users, errors = as_collection(:users, query(first: 1, skip: 2), current_user: super_user)
          expect(errors).to be_nil
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
            node { id email name phone role department }
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
    params = args[:roleIds] ? ["roleIds: #{args[:roleIds]}"] : []
    params << "departments: #{args[:departments]}" if args[:departments].present?
    params << "active: #{args[:active]}" unless args[:active].nil?
    params << "query: \"#{args[:query]}\"" if args[:query]
    params << "first: #{args[:first]}" if args[:first]
    params << "skip: #{args[:skip]}" if args[:skip]

    params.empty? ? nil : "(#{params.join(',')})"
  end
end
