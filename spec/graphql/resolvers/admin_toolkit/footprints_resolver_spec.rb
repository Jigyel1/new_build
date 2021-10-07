# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::AdminToolkit::FootprintsResolver do
  let_it_be(:footprint_type) { create(:admin_toolkit_footprint_type) }
  let_it_be(:footprint_type_b) { create(:admin_toolkit_footprint_type, index: 1, provider: :both) }
  let_it_be(:footprint_apartment) { create(:admin_toolkit_footprint_apartment) }
  let_it_be(:footprint_apartment_b) { create(:admin_toolkit_footprint_apartment, index: 1, min: 6, max: 12) }

  let_it_be(:footprint_value) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type, footprint_apartment: footprint_apartment
    )
  end

  let_it_be(:footprint_value_b) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type, footprint_apartment: footprint_apartment_b
    )
  end

  let_it_be(:footprint_value_c) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type_b, footprint_apartment: footprint_apartment
    )
  end

  let_it_be(:footprint_value_d) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type_b, footprint_apartment: footprint_apartment_b
    )
  end

  describe '.resolve' do
    context 'for admins' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'returns all footprint values' do
        response, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(response.adminToolkitFootprints.pluck(:id)).to match_array(
          [
            footprint_value.id, footprint_value_b.id, footprint_value_c.id, footprint_value_d.id
          ]
        )
      end
    end

    context 'for non admins' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam)
        expect(response.adminToolkitFootprints).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query {
        adminToolkitFootprints {
          id category
          footprintType { index provider }
          footprintApartment { index min max}
        }
      }
    GQL
  end
end
