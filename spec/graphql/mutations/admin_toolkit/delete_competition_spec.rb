# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::AdminToolkit::DeleteCompetition do
  let_it_be(:competition) { create(:admin_toolkit_competition) }

  describe '.resolve' do
    context 'with permissions' do
      let_it_be(:super_user) { create(:user, :super_user) }

      it 'deletes the competition record' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteCompetition)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { AdminToolkit::Competition.find(competition.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      let_it_be(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteCompetition)
        expect(response.competition).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteCompetition( input: { id: "#{competition.id}" } )
        { status }
      }
    GQL
  end
end
