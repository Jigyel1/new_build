# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::CompetitionDeleter do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:competition) { create(:admin_toolkit_competition) }
  let_it_be(:params) { { id: competition.id } }

  before_all { ::AdminToolkit::CompetitionDeleter.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)

        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        attributes = competition.attributes.slice('name', 'factor', 'lease_rate')
        attributes['lease_rate'] = attributes['lease_rate'].to_s # big_decimal not formatted correctly

        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.competition_deleted.owner',
            trackable_id: competition.id,
            parameters: attributes.stringify_keys)
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)

        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        attributes = competition.attributes.slice('name', 'factor', 'lease_rate')
        attributes['lease_rate'] = attributes['lease_rate'].to_s # big_decimal not formatted correctly

        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.competition_deleted.others',
            trackable_id: competition.id,
            owner_email: super_user.email,
            parameters: attributes.stringify_keys)
        )
      end
    end
  end
end
