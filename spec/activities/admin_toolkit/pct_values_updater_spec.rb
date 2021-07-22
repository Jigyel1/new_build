require 'rails_helper'

describe AdminToolkit::PctValuesUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:pct_cost) { create(:admin_toolkit_pct_cost) }
  let_it_be(:pct_month) { create(:admin_toolkit_pct_month) }

  let_it_be(:pct_value) do
    create(
      :admin_toolkit_pct_value,
      pct_cost: pct_cost, 
      pct_month: pct_month
    )
  end

  let_it_be(:pct_value_b) do
    create(
      :admin_toolkit_pct_value,
      status: 'Prio 2',
      pct_cost: pct_cost, 
      pct_month: pct_month
    )
  end

  let_it_be(:params) do
    [
      { id: pct_value.id, status: 'On Hold' },
      { id: pct_value_b.id, status: 'Prio 2' }
    ]
  end

  describe '.activities' do
    before { ::AdminToolkit::PctValuesUpdater.new(current_user: super_user, attributes: params).call }

    context 'as an owner' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.pct_value_updated.owner', parameters: params.map(&:stringify_keys))
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.pct_value_updated.others',
            owner_email: super_user.email,
            parameters: params.map(&:stringify_keys))
        )
      end
    end
  end

  def activities_query
    <<~GQL
      query {
        activities {
          totalCount
          edges {
            node {
              id createdAt displayText
            }
          }
        }
      }
    GQL
  end
end