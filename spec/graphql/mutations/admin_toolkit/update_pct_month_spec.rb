# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdatePctMonth do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:pct_month) { create(:admin_toolkit_pct_month) }
  let_it_be(:pct_month_b) { create(:admin_toolkit_pct_month, index: 1, min: 13, max: 18) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { id: pct_month.id, max: 16 } }

      it 'updates PCT month' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePctMonth)
        expect(errors).to be_nil
        expect(response.pctMonth).to have_attributes(max: 16)
      end

      it 'propagates update to the next PCT month table' do
        _, errors = formatted_response(query(params), current_user: super_user, key: :updatePctMonth)
        expect(errors).to be_nil
        expect(pct_month_b.reload).to have_attributes(min: 16)
      end
    end

    context 'with invalid params' do
      let!(:params) { { id: pct_month.id, max: 0 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updatePctMonth)
        expect(response.pctMonth).to be_nil
        expect(errors).to match_array(['Max must be greater than or equal to 1'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updatePctMonth(
          input: {
            attributes: {
              id: "#{args[:id]}"
              max: #{args[:max]}
            }
          }
        )
        { pctMonth { id max min } }
      }
    GQL
  end
end
