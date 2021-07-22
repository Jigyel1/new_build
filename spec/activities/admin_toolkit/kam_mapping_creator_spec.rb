require 'rails_helper'

describe AdminToolkit::KamMappingCreator do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:investor_id) { '8741a6d80de7f8d70c1a027c1fa1eab2' }
  let_it_be(:params) {{ kam_id: kam.id, investor_id: investor_id }}

  describe '.activities' do
    before { ::AdminToolkit::KamMappingCreator.new(current_user: super_user, attributes: params).call }

    context 'as an owner' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.kam_mapping_created.owner',
            recipient_email: kam.email,
            investor_id: investor_id)
        )
      end
    end

    context 'as an recipient' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.kam_mapping_created.recipient',
            owner_email: super_user.email,
            investor_id: investor_id)
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
          t('activities.admin_toolkit.kam_mapping_created.others',
            owner_email: super_user.email,
            recipient_email: kam.email,
            investor_id: investor_id)
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