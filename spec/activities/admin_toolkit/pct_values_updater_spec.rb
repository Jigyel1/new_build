# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::PctValuesUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:pct_cost) { create(:admin_toolkit_pct_cost) }
  let_it_be(:pct_month) { create(:admin_toolkit_pct_month) }
  let_it_be(:pct_value) { create(:admin_toolkit_pct_value, pct_cost: pct_cost, pct_month: pct_month) }

  let_it_be(:pct_value_b) do
    create(
      :admin_toolkit_pct_value,
      status: 'Prio 2',
      pct_cost: pct_cost,
      pct_month: pct_month
    )
  end

  let_it_be(:params) { [{ id: pct_value.id, status: 'on_hold' }, { id: pct_value_b.id, status: 'Prio 2' }] }

  before_all { ::AdminToolkit::PctValuesUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.pct_value_updated.owner', min: pct_month.min,
                                                                max: pct_month.max,
                                                                min_cost: pct_cost.min,
                                                                max_cost: pct_cost.max,
                                                                status: params.dig(0, :status))
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
          t('activities.admin_toolkit.pct_value_updated.others',
            owner_email: super_user.email,
            min: pct_month.min,
            max: pct_month.max,
            min_cost: pct_cost.min,
            max_cost: pct_cost.max,
            status: params.dig(0, :status))
        )
      end
    end
  end
end
