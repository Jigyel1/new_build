# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::PenetrationCreator do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam_region) { create(:kam_region, name: 'Ost ZH') }

  let_it_be(:params) do
    {
      zip: '1008',
      city: 'Jouxtens-Mézery',
      rate: 77,
      type: 'top_city',
      hfc_footprint: false,
      kam_region_id: kam_region.id
    }
  end

  before_all { ::AdminToolkit::PenetrationCreator.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.penetration_created.owner', zip: params[:zip])
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activities in third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.penetration_created.others',
            owner_email: super_user.email,
            zip: params[:zip])
        )
      end
    end
  end
end
