# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateFootprintBuilding do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:footprint_building) { create(:admin_toolkit_footprint_building) }
  let_it_be(:footprint_building_b) { create(:admin_toolkit_footprint_building, index: 1, min: 6, max: 12) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { id: footprint_building.id, max: 3 } }

      it 'updates PCT data' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintBuilding)
        expect(errors).to be_nil
        expect(response.footprintBuilding).to have_attributes(max: 3)
      end

      it 'propagates update to the next PCT table' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintBuilding)
        expect(errors).to be_nil
        expect(footprint_building_b.reload).to have_attributes(min: 4)
      end
    end

    context 'with invalid params' do
      let!(:params) { { id: footprint_building.id, max: 0 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintBuilding)
        expect(response.footprintBuilding).to be_nil
        expect(errors).to match_array(["Max must be greater than 0 and Max must be greater than or equal to 1"])
      end
    end

    context 'when max exceeds or is equal to the PCT max of the adjacent table' do
      let!(:params) { { id: footprint_building.id, max: 12  } } # 11 sh work, sh fail with 12

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintBuilding)
        expect(response.footprintBuilding).to be_nil
        expect(errors).to match_array([
                                        t('admin_toolkit.footprint_building.invalid_min',
                                          header: footprint_building_b.header,
                                          new_max: 13,
                                          old_max: 12
                                        )
                                      ])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateFootprintBuilding(
          input: {
            attributes: {
              id: "#{args[:id]}"
              max: #{args[:max]} 
            }
          }
        )
        { footprintBuilding { id max min header } }
      }
    GQL
  end
end
