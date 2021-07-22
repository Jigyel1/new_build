require 'rails_helper'

describe AdminToolkit::PenetrationCreator do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:params) do
    {
      zip: '1008',
      city: 'Jouxtens-Mézery',
      rate: 77,
      type: 'top_city',
      kam_region: 'Ost ZH',
      competition: 'FTTH Swisscom',
      hfc_footprint: false
    }
  end

  describe '.activities' do
    before { ::AdminToolkit::PenetrationCreator.new(current_user: super_user, attributes: params).call }

    context 'as an owner' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        activity = activities.first
        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.penetration_created.owner', parameters: params.stringify_keys)
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
            t('activities.admin_toolkit.penetration_created.others',
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