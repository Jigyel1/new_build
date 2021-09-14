# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::CompetitionUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:competition) { create(:admin_toolkit_competition) }
  let_it_be(:params) { { id: competition.id, name: 'FTTH SC', factor: 1.55 } }

  before_all { ::AdminToolkit::CompetitionUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.competition_updated.owner',
            name: params.dig(:name))
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
          t('activities.admin_toolkit.competition_updated.others',
            owner_email: super_user.email,
            name: params.dig(:name))
        )
      end
    end
  end
end
