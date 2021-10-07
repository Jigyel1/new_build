# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateFootprintApartment do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:footprint_apartment) { create(:admin_toolkit_footprint_apartment) }
  let_it_be(:footprint_apartment_b) { create(:admin_toolkit_footprint_apartment, index: 1, min: 6, max: 12) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { id: footprint_apartment.id, max: 3 } }

      it 'updates footprint apartment data' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintApartment)
        expect(errors).to be_nil
        expect(response.footprintApartment).to have_attributes(max: 3)
      end

      it 'propagates update to the next footprint apartment table' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintApartment)
        expect(errors).to be_nil
        expect(footprint_apartment_b.reload).to have_attributes(min: 4)
      end
    end

    context 'with invalid params' do
      let!(:params) { { id: footprint_apartment.id, max: 0 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintApartment)
        expect(response.footprintApartment).to be_nil
        expect(errors).to match_array(['Max must be greater than 0 and Max must be greater than or equal to 1'])
      end
    end

    context 'when max exceeds or is equal to the footprint apartment max of the adjacent table' do
      let!(:params) { { id: footprint_apartment.id, max: 12 } } # 11 sh work, sh fail with 12

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintApartment)
        expect(response.footprintApartment).to be_nil
        expect(errors).to match_array(
          [
            t('admin_toolkit.footprint_apartment.invalid_min',
              index: footprint_apartment_b.index,
              new_max: 13,
              old_max: 12)
          ]
        )
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateFootprintApartment(
          input: {
            attributes: {
              id: "#{args[:id]}"
              max: #{args[:max]}
            }
          }
        )
        { footprintApartment { id max min } }
      }
    GQL
  end
end
