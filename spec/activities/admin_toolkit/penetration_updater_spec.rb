# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::PenetrationUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam_region) { create(:kam_region) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, kam_region: kam_region) }
  let_it_be(:params) { { id: penetration.id, zip: '1009', city: 'Pully' } }

  before_all { ::AdminToolkit::PenetrationUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.penetration_updated.owner',
            zip: params[:zip])
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
          t('activities.admin_toolkit.penetration_updated.others',
            owner_email: super_user.email,
            zip: params[:zip])
        )
      end
    end
  end
end
