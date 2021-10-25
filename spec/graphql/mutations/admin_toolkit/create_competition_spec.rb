# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::CreateCompetition do
  let_it_be(:super_user) { create(:user, :super_user) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { factor: 1.3 } }

      it 'creates the competition record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createCompetition)
        expect(errors).to be_nil
        expect(response.competition).to have_attributes(
          factor: 1.3,
          sfn: true,
          leaseRate: '119.9834',
          name: 'FTTH SC & EVU',
          description: 'Very high competition (fiber areas such as Zurich, Bern, Lucerne, etc.)'
        )
      end
    end

    context 'with invalid params' do
      let!(:params) { { factor: -0.3 } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createCompetition)
        expect(response.competition).to be_nil
        expect(errors).to match_array(['Factor must be greater than or equal to 0'])
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }
      let!(:params) { { factor: 1.3 } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :createCompetition)
        expect(response.competition).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        createCompetition(
          input: {
            attributes: {
              factor: #{args[:factor]}
              sfn: true
              leaseRate: "119.9834"
              name: "FTTH SC & EVU"
              description: "Very high competition (fiber areas such as Zurich, Bern, Lucerne, etc.)"
            }
          }
        )
        { competition { id sfn factor leaseRate name description } }
      }
    GQL
  end
end
