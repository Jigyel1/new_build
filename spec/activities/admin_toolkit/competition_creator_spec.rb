require 'rails_helper'

describe AdminToolkit::CompetitionCreator do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:params) do
    {
      name: 'FTTH SC & EVU',
      factor: 1.35,
      lease_rate: 77
    }
  end

  describe '.activities' do
    before { ::AdminToolkit::CompetitionCreator.new(current_user: super_user, attributes: params).call }

    context 'as an owner' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.competition_created.owner', parameters: params.stringify_keys)
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
            t('activities.admin_toolkit.competition_created.others',
              owner_email: super_user.email,
              parameters: params.stringify_keys)
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