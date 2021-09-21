# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::KamInvestorUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_b) { create(:user, :kam) }

  let_it_be(:investor_id) { '8741a6d80de7f8d70c1a027c1fa1eab2' }
  let_it_be(:kam_investor) { create(:admin_toolkit_kam_investor, kam: kam) }
  let_it_be(:params) { { id: kam_investor.id, kam_id: kam_b.id, investor_id: investor_id } }

  before_all { ::AdminToolkit::KamInvestorUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.kam_investor_updated.owner',
            recipient_email: kam_b.email)
        )
      end
    end

    context 'as an recipient' do
      it 'returns activity text in terms of a second person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: kam_b)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.kam_investor_updated.recipient',
            owner_email: super_user.email)
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
          t('activities.admin_toolkit.kam_investor_updated.others',
            recipient_email: kam_b.email,
            owner_email: super_user.email)
        )
      end
    end
  end
end
