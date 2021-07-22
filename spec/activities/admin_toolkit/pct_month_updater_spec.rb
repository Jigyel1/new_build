require 'rails_helper'

describe AdminToolkit::PctMonthUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:pct_month) { create(:admin_toolkit_pct_month) }
  let_it_be(:params) {{ id: pct_month.id, max: 1000 }}

  describe '.activities' do
    before { ::AdminToolkit::PctMonthUpdater.new(current_user: super_user, attributes: params).call }

    context 'as an owner' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.pct_month_updated.owner',
            trackable_id: pct_month.id,
            parameters: params.except(:id).stringify_keys)
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
          t('activities.admin_toolkit.pct_month_updated.others',
            trackable_id: pct_month.id,
            owner_email: super_user.email,
            parameters: params.except(:id).stringify_keys)
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