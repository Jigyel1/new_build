# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::BuildingResolver do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :read }) }
  let_it_be(:address) { build(:address) }
  let_it_be(:project) { create(:project, address: address) }
  let_it_be(:building) do
    create(
      :building,
      project: project,
      tasks: [
        build(:task, :to_do, owner: super_user, assignee: super_user),
        build(:task, :to_do, owner: super_user, assignee: super_user),
        build(:task, :in_progress, owner: super_user, assignee: super_user),
        build(:task, :completed, owner: super_user, assignee: super_user),
        build(:task, :archived, owner: super_user, assignee: super_user)
      ]
    )
  end

  describe '.resolve' do
    context 'with read permission' do
      it 'returns building details' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil

        expect(data.building).to have_attributes(
          id: building.id,
          name: building.name,
          tasks: '1/4'
        )

        expect(data.building.address).to have_attributes(
          streetNo: address.street_no,
          street: address.street,
          city: address.city,
          zip: address.zip
        )
      end
    end

    context 'without read permission' do
      let!(:manager_commercialization) { create(:user, :manager_commercialization) }

      it 'forbids action' do
        data, errors = formatted_response(query, current_user: manager_commercialization)
        expect(data.building).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query {
        building(id: "#{building.id}")
        { id name tasks address { street streetNo zip city } }
      }
    GQL
  end
end
