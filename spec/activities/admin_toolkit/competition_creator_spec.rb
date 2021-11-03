# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::CompetitionCreator do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:params) { { name: 'FTTH SC & EVU', factor: 1.35, lease_rate: 77 } }

  before_all { ::AdminToolkit::CompetitionCreator.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in the first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.competition_created.owner', name: params[:name])
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
          t('activities.admin_toolkit.competition_created.others',
            owner_email: super_user.email,
            name: params[:name])
        )
      end
    end
  end
end
