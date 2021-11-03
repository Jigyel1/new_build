# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::PenetrationDeleter do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam_region) { create(:kam_region) }
  let_it_be(:penetration) { create(:admin_toolkit_penetration, kam_region: kam_region) }
  let_it_be(:params) { { id: penetration.id } }

  before_all { ::AdminToolkit::PenetrationDeleter.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)

        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        attributes = penetration.attributes.slice(
          'zip', 'city', 'rate', 'type', 'kam_region', 'competition', 'hfc_footprint'
        )

        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.penetration_deleted.owner',
            zip: attributes['zip'])
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activities in third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)

        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        attributes = penetration.attributes.slice(
          'zip', 'city', 'rate', 'type', 'kam_region', 'competition', 'hfc_footprint'
        )

        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.penetration_deleted.others',
            owner_email: super_user.email,
            zip: attributes['zip'])
        )
      end
    end
  end
end
