# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateFootprintValues do
  let_it_be(:super_user) { create(:user, :super_user) }
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
    context 'with valid params' do
      it 'updates footprint values' do
        response, errors = formatted_response(
          query(category: :irrelevant), current_user: super_user, key: :updateFootprintValues
        )
        expect(errors).to be_nil

        value = response.footprintValues.find { _1[:id] == footprint_value_b.id }
        expect(value[:category]).to eq('standard')
        value = response.footprintValues.find { _1[:id] == footprint_value_c.id }
        expect(value[:category]).to eq('irrelevant')
        value = response.footprintValues.find { _1[:id] == footprint_value_d.id }
        expect(value[:category]).to eq('irrelevant')
      end
    end

    context 'with invalid params' do
      it 'responds with error' do
        response, errors = formatted_response(
          query(category: :invalid), current_user: super_user, key: :updateFootprintValues
        )
        expect(response.footprintValues).to be_nil
        expect(errors).to eq(["'invalid' is not a valid category"])
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
                category: "standard"
              },
              {
                id: "#{footprint_value_c.id}"
                category: "irrelevant"
              },
              {
                id: "#{footprint_value_d.id}"
                category: "#{args[:category]}"
              }
            ]
          }
        )
        { footprintValues { id category } }
      }
    GQL
  end
end
