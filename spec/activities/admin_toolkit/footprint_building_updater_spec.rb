# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::FootprintBuildingUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:footprint_building) { create(:admin_toolkit_footprint_building) }
  let_it_be(:params) { { id: footprint_building.id, max: 10 } }

  before_all { ::AdminToolkit::FootprintBuildingUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.footprint_building_updated.owner',
            trackable_id: footprint_building.id,
            parameters: params.except(:id).stringify_keys)
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
          t('activities.admin_toolkit.footprint_building_updated.others',
            trackable_id: footprint_building.id,
            owner_email: super_user.email,
            parameters: params.except(:id).stringify_keys)
        )
      end
    end
  end
end
