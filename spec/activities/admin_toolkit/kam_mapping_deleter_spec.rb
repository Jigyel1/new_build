# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::KamMappingDeleter do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_mapping) { create(:admin_toolkit_kam_mapping, kam: kam) }
  let_it_be(:params) { { id: kam_mapping.id } }

  before_all { ::AdminToolkit::KamMappingDeleter.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.kam_mapping_deleted.owner',
            parameters: kam_mapping.attributes.slice('kam_id', 'investor_id').stringify_keys,
            trackable_id: kam_mapping.id)
        )
      end
    end

    context 'as an recipient' do
      it 'returns activity text in terms of a second person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.kam_mapping_deleted.recipient',
            parameters: kam_mapping.attributes.slice('kam_id', 'investor_id').stringify_keys,
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
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.kam_mapping_deleted.others',
            parameters: kam_mapping.attributes.slice('kam_id', 'investor_id').stringify_keys,
            owner_email: super_user.email,
            trackable_id: kam_mapping.id)
        )
      end
    end
  end
end
