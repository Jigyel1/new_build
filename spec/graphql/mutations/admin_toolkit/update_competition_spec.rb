# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::UpdateCompetition do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:competition) { create(:admin_toolkit_competition) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { id: competition.id, factor: 0.45 } }

      it 'updates the competition record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateCompetition)
        expect(errors).to be_nil
        expect(response.competition).to have_attributes(factor: 0.45, leaseRate: '119.9834')
      end
    end

    context 'with invalid params' do
      let!(:params) { { id: competition.id, factor: -4.5 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateCompetition)
        expect(response.competition).to be_nil
        expect(errors).to match_array(['Factor must be greater than or equal to 0'])
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }
      let!(:params) { { id: competition.id, factor: 4.5 } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateCompetition)
        expect(response.competition).to be_nil
        expect(errors).to match_array(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateCompetition(
          input: {
            attributes: {
              id: "#{args[:id]}"
              factor: #{args[:factor]}
              leaseRate: "119.9834"
            }
          }
        )
        { competition { id factor leaseRate name description } }
      }
    GQL
  end
end
