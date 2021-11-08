# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::FootprintValuesUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:footprint_type) { create(:admin_toolkit_footprint_type) }
  let_it_be(:footprint_apartment) { create(:admin_toolkit_footprint_apartment) }

  let_it_be(:footprint_value) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type, footprint_apartment: footprint_apartment
    )
  end

  let_it_be(:footprint_value_b) do
    create(
      :admin_toolkit_footprint_value,
      category: :marketing_only,
      footprint_type: footprint_type, footprint_apartment: footprint_apartment
    )
  end

  let_it_be(:params) do
    [
      { id: footprint_value.id, category: 'irrelevant' },
      { id: footprint_value_b.id, category: 'complex' }
    ]
  end

  before_all { ::AdminToolkit::FootprintValuesUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.footprint_value_updated.owner')
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
          t('activities.admin_toolkit.footprint_value_updated.others',
            owner_email: super_user.email)
        )
      end
    end
  end
end
