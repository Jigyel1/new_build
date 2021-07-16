# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateFootprintValues do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:footprint_type) { create(:admin_toolkit_footprint_type) }
  let_it_be(:footprint_type_b) { create(:admin_toolkit_footprint_type, index: 1, provider: :both) }
  let_it_be(:footprint_building) { create(:admin_toolkit_footprint_building) }
  let_it_be(:footprint_building_b) { create(:admin_toolkit_footprint_building, index: 1, min: 6, max: 12) }

  let_it_be(:footprint_value) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type, footprint_building: footprint_building
    )
  end

  let_it_be(:footprint_value_b) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type, footprint_building: footprint_building_b
    )
  end

  let_it_be(:footprint_value_c) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type_b, footprint_building: footprint_building
    )
  end

  let_it_be(:footprint_value_d) do
    create(
      :admin_toolkit_footprint_value,
      footprint_type: footprint_type_b, footprint_building: footprint_building_b
    )
  end

  describe '.resolve' do
    context 'with valid params' do
      it 'updates PCT data' do
        response, errors = formatted_response(query(project_type: :irrelevant), current_user: super_user, key: :updateFootprintValues)
        expect(errors).to be_nil

        value = response.footprintValues.find { _1[:id] == footprint_value_b.id }
        expect(value[:projectType]).to eq('standard')
        value = response.footprintValues.find { _1[:id] == footprint_value_c.id }
        expect(value[:projectType]).to eq('irrelevant')
        value = response.footprintValues.find { _1[:id] == footprint_value_d.id }
        expect(value[:projectType]).to eq('irrelevant')
      end
    end

    context 'with invalid params' do
      it 'responds with error' do
        response, errors = formatted_response(query(project_type: :invalid), current_user: super_user, key: :updateFootprintValues)
        expect(response.footprintValues).to be_nil
        expect(errors).to eq(["'invalid' is not a valid project_type"])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateFootprintValues(
          input: {
            attributes: [
              {
                id: "#{footprint_value_b.id}"
                projectType: "standard"              
              },
              {
                id: "#{footprint_value_c.id}"
                projectType: "irrelevant"              
              },
              {
                id: "#{footprint_value_d.id}"
                projectType: "#{args[:project_type]}"              
              }
            ]
          }
        )
        { footprintValues { id projectType } }
      }
    GQL
  end
end
