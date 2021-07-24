# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::PenetrationDeleter do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration) }
  let_it_be(:params) { { id: penetration.id } }

  describe '.activities' do
    before { ::AdminToolkit::PenetrationDeleter.new(current_user: super_user, attributes: params).call }

    context 'as an owner' do
      it 'returns activity text' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)

        expect(errors).to be_nil
        activity = activities.first
        attributes = penetration.attributes.slice(
          'zip', 'city', 'rate', 'type', 'kam_region', 'competition', 'hfc_footprint'
        )

        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.penetration_deleted.owner',
            trackable_id: penetration.id,
            parameters: attributes.stringify_keys)
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)

        expect(errors).to be_nil
        activity = activities.first
        attributes = penetration.attributes.slice(
          'zip', 'city', 'rate', 'type', 'kam_region', 'competition', 'hfc_footprint'
        )

        expect(activity[:displayText]).to eq(
          t('activities.admin_toolkit.penetration_deleted.others',
            trackable_id: penetration.id,
            owner_email: super_user.email,
            parameters: attributes.stringify_keys)
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
