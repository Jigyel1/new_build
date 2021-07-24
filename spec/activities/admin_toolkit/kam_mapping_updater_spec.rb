# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::KamMappingUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_b) { create(:user, :kam) }

  let_it_be(:investor_id) { '8741a6d80de7f8d70c1a027c1fa1eab2' }
  let_it_be(:kam_mapping) { create(:admin_toolkit_kam_mapping, kam: kam) }
  let_it_be(:params) { { id: kam_mapping.id, kam_id: kam_b.id, investor_id: investor_id } }

  describe '.activities' do
    before { ::AdminToolkit::KamMappingUpdater.new(current_user: super_user, attributes: params).call }

    context 'as an owner' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.kam_mapping_updated.owner',
            parameters: params.except(:id).stringify_keys,
            trackable_id: kam_mapping.id)
        )
      end
    end

    context 'as an recipient' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: kam_b)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.kam_mapping_updated.recipient',
            parameters: params.except(:id).stringify_keys,
            owner_email: super_user.email,
            trackable_id: kam_mapping.id)
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
          t('activities.admin_toolkit.kam_mapping_updated.others',
            parameters: params.except(:id).stringify_keys,
            owner_email: super_user.email,
            trackable_id: kam_mapping.id)
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
