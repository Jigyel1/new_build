# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::CreateProject do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:management) { create(:user, :management) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) do 
        { status: 'Technical Analysis', assignee_id: management.id, move_in_starts_on: Date.current } 
      end

      it 'creates the competition record' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createProject)
        expect(errors).to be_nil
        expect(response.project).to have_attributes(
                                      externalId: 'e922833',
                                      moveInStartsOn: Date.current.in_time_zone.date_str,
                                      status: 'Technical Analysis'
                                    )

        byebug
        expect(response.project.assignee)
      end
    end


    # context 'with invalid assignee'
    # context 'with assignee '

    # context 'with invalid params' do
    #   let!(:params) { { factor: -0.3 } }
    #
    #   it 'responds with error' do
    #     response, errors = formatted_response(query(params), current_user: super_user, key: :draftProject)
    #     expect(response.competition).to be_nil
    #     expect(errors).to match_array(['Factor must be greater than or equal to 0'])
    #   end
    # end
    #
    # context 'without permissions' do
    #   let!(:kam) { create(:user, :kam) }
    #   let!(:params) { { factor: 1.3 } }
    #
    #   it 'forbids action' do
    #     response, errors = formatted_response(query(params), current_user: kam, key: :draftProject)
    #     expect(response.competition).to be_nil
    #     expect(errors).to eq(['Not Authorized'])
    #   end
    # end
  end

  def query(args = {})
    <<~GQL
      mutation {
        createProject(
          input: {
            attributes: {
              externalId: "e922833"
              status: "#{args[:status]}"
              moveInStartsOn: "#{args[:move_in_starts_on]}"
              assigneeId: "#{args[:assignee_id]}"
            }
          }
        )
        { project { id status moveInStartsOn assignee { id name } } }
      }
    GQL
  end
end
