# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateBuilding do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { name: "Construction d'une habitation de quatre logements" } }

      it 'updates the building' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateBuilding)
        expect(errors).to be_nil
        expect(response.building).to have_attributes(
          externalId: '100202',
          name: "Construction d'une habitation de quatre logements",
          moveInStartsOn: Date.current.next_month.to_s
        )

        expect(response.building.address).to have_attributes(
          street: 'Turcotte Bridge',
          streetNo: '7361',
          city: 'Port Rosemary',
          zip: '31471'
        )
        expect(response.building.assignee).to have_attributes(id: super_user.id, name: super_user.name)
      end

      it 'propagates move in date changes to the project' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updateBuilding)
        expect(errors).to be_nil
        expect(project.reload).to have_attributes(
          move_in_starts_on: Date.current.next_month,
          move_in_ends_on: Date.current.next_month
        )
      end

      it 'propagates apartments count to projects list' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updateBuilding)
        expect(errors).to be_nil
        expect(ProjectsList.find(project.id).apartments_count).to eq(55)
      end
    end

    context 'with invalid params' do
      let!(:params) { { apartments_count: - 1 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateBuilding)
        expect(response.building).to be_nil
        expect(errors).to eq(['Apartments count must be greater than 0'])
      end
    end

    context 'without permissions' do
      let!(:params) { { name: "Construction d'une habitation de quatre logements" } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: create(:user, :kam), key: :updateBuilding)
        expect(response.building).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def address
    <<~ADDRESS
      address: {
        id: "#{building.address.id}"
        street: "Turcotte Bridge"
        streetNo: "7361"
        city: "Port Rosemary"
        zip: "31471"
      }
    ADDRESS
  end

  def query(args = {})
    apartments = args[:apartments_count] || 55
    <<~GQL
      mutation {
        updateBuilding(
          input: {
            attributes: {
              id: "#{building.id}"
              name: "#{args[:name]}"
              assigneeId: "#{super_user.id}"
              apartmentsCount: #{apartments}
              externalId: "100202"
              moveInStartsOn: "#{Date.current + 1.month}"
              #{address}
            }
          }
        )
        {
          building {
            id name externalId apartmentsCount moveInStartsOn
            address { id streetNo street city zip}
            assignee { id name }
          }
        }
      }
    GQL
  end
end
