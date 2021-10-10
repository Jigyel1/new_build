# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::KamRegionsUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_b) { create(:user, :kam) }

  let_it_be(:kam_region) { create(:kam_region, kam: kam) }
  let_it_be(:params) { [{ id: kam_region.id, kam_id: kam_b.id }] }

  before_all { ::AdminToolkit::KamRegionsUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.kam_region_updated.owner')
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
          t('activities.admin_toolkit.kam_region_updated.others', owner_email: super_user.email)
        )
      end
    end
  end
end
