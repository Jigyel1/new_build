# frozen_string_literal: true

require 'rails_helper'

describe Projects::BuildingCreator do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project) }
  let_it_be(:params) do
    {
      project_id: project.id,
      name: "Construction d'une habitation de quatre logements",
      address_attributes: {
        zip: '123',
        street: Faker::Address.street_name.to_s,
        street_no: Faker::Address.building_number.to_s,
        city: Faker::Address.city.to_s
      }
    }
  end

  before_all { described_class.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in the first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.building_created.owner',
            name: params[:name],
            project_name: project.name)
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.building_created.others',
            name: params[:name],
            project_name: project.name,
            owner_email: super_user.email)
        )
      end
    end
  end
end
