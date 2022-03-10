# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::UpdateProject do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project, assignee: kam) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { status: 'Technical Analysis', assignee_id: kam.id } }

      it 'updates the project' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateProject)
        expect(errors).to be_nil
        expect(response.project).to have_attributes(
          internalId: 'e922833',
          status: 'technical_analysis',
          assigneeType: 'nbo',
          buildingType: 'stepped_building',
          gisUrl: 'https://web.upc.ch/web_office/server?project=Access&client=corejs&keyname=PROJ_EXTERN_ID&keyvalue=3045071',
          infoManagerUrl: 'https://infomanager.bauinfocenter.ch/go/projectext/3045071'
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
        response, errors = formatted_response(
          query(params),
          current_user: create(:user, :manager_commercialization),
          key: :updateProject
        )
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'when the project assignee is changed' do
      context 'when current user is assigned to project' do
        let!(:params) { { status: 'Technical Analysis', assignee_id: super_user.id } }

        it 'sends unassigned email to previous assignee' do
          perform_enqueued_jobs do
            _response, errors = formatted_response(query(params), current_user: super_user, key: :updateProject)
            expect(errors).to be_nil
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(ActionMailer::Base.deliveries.first).to have_attributes(
              subject: t('mailer.project.notify_assignee_unassigned'),
              to: [kam.email]
            )
          end
        end
      end

      context 'when current user is previous project assignee' do
        before { project.update(assignee: super_user) }

        let!(:params) { { status: 'Technical Analysis', assignee_id: kam.id } }

        it 'sends assigned email to new assignee' do
          perform_enqueued_jobs do
            _response, errors = formatted_response(query(params), current_user: super_user, key: :updateProject)
            expect(errors).to be_nil
            expect(ActionMailer::Base.deliveries.count).to eq(1)
            expect(ActionMailer::Base.deliveries.first).to have_attributes(
              subject: t('mailer.project.notify_assignee_assigned'),
              to: [kam.email]
            )
          end
        end
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
              internalId: "e922833"
              assigneeId: "#{args[:assignee_id]}"
              status: "#{args[:status]}"
              lotNumber: "EA0988833"
              buildingType: "stepped_building"
              gisUrl: "https://web.upc.ch/web_office/server?project=Access&client=corejs&keyname=PROJ_EXTERN_ID&keyvalue=3045071"
              infoManagerUrl: "https://infomanager.bauinfocenter.ch/go/projectext/3045071"
              #{address}
            }
          }
        )
        {
          project {
            id status internalId moveInStartsOn gisUrl infoManagerUrl assigneeType buildingType
            assignee { id name }
            addressBooks {
              id type name company language email website phone mobile
              address { id street city zip }
            }
          }
        }
      }
    GQL
  end
end
