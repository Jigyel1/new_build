# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateFootprintValues do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:footprint_type) { create(:admin_toolkit_footprint_type) }
  let_it_be(:footprint_type_b) { create(:admin_toolkit_footprint_type, index: 1, provider: :both) }
  let_it_be(:footprint_building) { create(:admin_toolkit_footprint_building) }
  let_it_be(:footprint_building_b) { create(:admin_toolkit_footprint_building, index: 1, min: 6, max: 12) }

  let_it_be(:footprint_value) do
    create(:admin_toolkit_footprint_value, footprint_type: footprint_type, footprint_building: footprint_building)
  end
  let_it_be(:footprint_value_b) do
    create(:admin_toolkit_footprint_value, footprint_type: footprint_type, footprint_building: footprint_building_b)
  end
  let_it_be(:footprint_value_c) do
    create(:admin_toolkit_footprint_value, footprint_type: footprint_type_b, footprint_building: footprint_building)
  end
  let_it_be(:footprint_value_d) do
    create(:admin_toolkit_footprint_value, footprint_type: footprint_type_b, footprint_building: footprint_building_b)
  end

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) do
        [
          [footprint_value_b.id, 'standard'],
          [footprint_value_c.id, 'irrelevant'],
          [footprint_value_d.id, 'irrelevant']
        ]
      end

      it 'updates PCT data' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updateFootprintValues)
        expect(errors).to be_nil
        expect(footprint_value_b.reload.project_type).to eq('standard')
        expect(footprint_value_c.reload.project_type).to eq('irrelevant')
        expect(footprint_value_d.reload.project_type).to eq('irrelevant')
      end
    end
  end

  def query(params)
    <<~GQL
      mutation {
        updateFootprintValues(
          input: {
            attributes: {
              footprintValues: #{params}
            }
          }
        )
        { footprintValues { id projectType } }
      }
    GQL
  end
end
