# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProject do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { status: 'Technical Analysis' } }

      it 'creates the project' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateProject)
        expect(errors).to be_nil
        expect(response.project).to have_attributes(
          externalId: 'e922833',
          status: 'Technical Analysis',
          assignee: nil,
          assigneeType: 'KAM Project'
        )
      end
    end

    context 'with invalid params' do
      let!(:params) { { status: 'Invalid Status' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateProject)
        expect(response.project).to be_nil
        expect(errors).to eq(["'Invalid Status' is not a valid status"])
      end
    end

    context 'without permissions' do
      let!(:params) { { status: 'Technical Analysis' } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: create(:user, :presales), key: :updateProject)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  # Pass id as an optional attribute. 
  def address
    <<~ADDRESS
      address: {
        street: "#{Faker::Address.street_name}",
        streetNo: "#{Faker::Address.building_number}"
        city: "#{Faker::Address.city}"
        zip: "8008"
      }
    ADDRESS
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateProject(
          input: {
            attributes: {
              id: "#{project.id}"
              externalId: "e922833"
              status: "#{args[:status]}"
              lotNumber: "EA0988833"
              #{address}
            }
          }
        )
        {
          project {
            id status externalId moveInStartsOn assigneeType assignee { id name }
            addressBooks { id type name company language email website phone mobile address { id street city zip} }
          }
        }
      }
    GQL
  end
end
