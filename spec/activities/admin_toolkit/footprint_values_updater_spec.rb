# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::FootprintValuesUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:footprint_type) { create(:admin_toolkit_footprint_type) }
  let_it_be(:footprint_building) { create(:admin_toolkit_footprint_building) }

  let_it_be(:footprint_value) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type, footprint_building: footprint_building
    )
  end

  let_it_be(:footprint_value_b) do
    create(
      :admin_toolkit_footprint_value,
      project_type: :marketing_only,
      footprint_type: footprint_type, footprint_building: footprint_building
    )
  end

  let_it_be(:params) do
    [
      { id: footprint_value.id, project_type: 'irrelevant' },
      { id: footprint_value_b.id, project_type: 'complex' }
    ]
  end

  before_all { ::AdminToolkit::FootprintValuesUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.footprint_value_updated.owner', parameters: params.map(&:stringify_keys))
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
          t('activities.admin_toolkit.footprint_value_updated.others',
            owner_email: super_user.email,
            parameters: params.map(&:stringify_keys))
        )
      end
    end
  end
end
