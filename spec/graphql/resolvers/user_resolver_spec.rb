# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::UserResolver do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { user: %i[read invite] }) }
  let_it_be(:address) { create(:address, addressable: super_user) }

  describe '.resolve' do
    context 'without id' do
      it 'returns current user details' do
        user, errors = formatted_response(query, current_user: super_user, key: :user)
        expect(errors).to be_nil

        expect(user).to have_attributes(
          email: super_user.email,
          id: super_user.id,
          name: super_user.name
        )

        profile = user.profile
        expect(profile).to have_attributes(
          firstname: profile.firstname,
          lastname: profile.lastname,
          salutation: profile.salutation,
          phone: profile.phone,
          department: profile.department
        )

        address = user.address
        expect(address).to have_attributes(
          streetNo: address.streetNo,
          street: address.street,
          zip: address.zip,
          city: address.city
        )
      end
    end

    context 'with id' do
      let!(:another_user) { create(:user, :team_standard) }

      it 'returns details of the given user' do
        user, errors = formatted_response(query(id: another_user.id), current_user: super_user, key: :user)
        expect(errors).to be_nil
        expect(user).to have_attributes(
          email: another_user.email,
          id: another_user.id,
          name: another_user.name
        )
      end
    end

    context 'with associations' do
      let_it_be(:kam) { create(:user, :kam) }
      let_it_be(:project_a) { create(:project, incharge: super_user, assignee: kam) }
      let_it_be(:project_b) { create(:project, incharge: kam, assignee: kam) }

      let_it_be(:building_a) { create(:building, project: project_a, assignee: kam) }
      let_it_be(:building_b) { create(:building, project: project_a, assignee: super_user) }

      let_it_be(:task_a) { create(:task, taskable: building_a, owner: super_user, assignee: kam) }
      let_it_be(:task_b) { create(:task, taskable: building_a, owner: kam, assignee: super_user) }
      let_it_be(:task_c) { create(:task, taskable: building_a, owner: kam, assignee: kam) }

      let_it_be(:kam_region) { create(:kam_region, kam: kam) }
      let_it_be(:kam_investor) { create(:kam_investor, kam: kam) }

      it 'returns association details' do
        user, errors = formatted_response(query(id: kam.id), current_user: super_user, key: :user)
        expect(errors).to be_nil
        expect(user).to have_attributes(
          buildingsCount: 1,
          projectsCount: 1,
          assignedProjectsCount: 2,
          assignedTasksCount: 2
        )

        expect(user.kamRegions.first[:id]).to eq(kam_region.id)
        expect(user.kamInvestors.first[:id]).to eq(kam_investor.id)
      end
    end

    context "when record doesn't exist" do
      it 'responds with error' do
        data, errors = formatted_response(
          query(id: '16c85b18-473d-4f5d-9ab4-666c7faceb6c\"'), current_user: super_user
        )

        expect(data.user).to be_nil
        expect(errors[0]).to include("Couldn't find Telco::Uam::User with 'id'=16c85b18-473d-4f5d-9ab4-666c7faceb6c\"")
      end
    end

    context 'without read permission' do
      let(:team_expert) { create(:user, :team_expert) }

      it 'forbids action' do
        data, errors = formatted_response(query(id: super_user.id), current_user: team_expert)
        expect(data.role).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      query {
        user#{query_string(args)} {
          id
          email
          name
          projectsCount
          assignedProjectsCount
          buildingsCount
          assignedTasksCount
          profile { firstname lastname salutation phone department }
          address { streetNo street city zip }
          kamRegions { id name kam { id name } }
          kamInvestors { id investorId kam { id name } }
        }
      }
    GQL
  end
end
