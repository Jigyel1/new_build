# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::DeleteBuilding do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }

  describe '.resolve' do
    context 'with permissions' do
      it 'deletes the building' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteBuilding)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { Projects::Task.find(building.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end

      it 'updates counter caches for the project' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteBuilding)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect(project.reload).to have_attributes(
          buildings_count: 0,
          apartments_count: 0
        )
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteBuilding)
        expect(response.building).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteBuilding(input: { id: "#{building.id}" } )
        { status }
      }
    GQL
  end
end
