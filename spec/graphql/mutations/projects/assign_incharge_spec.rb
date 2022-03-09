# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::AssignIncharge do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:super_user_b) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }

  describe '.resolve' do
    context 'with permissions' do
      it "updates project's incharge" do
        response, errors = formatted_response(query, current_user: super_user, key: :assignProjectIncharge)
        expect(errors).to be_nil
        expect(response.project.incharge).to have_attributes(id: kam.id, email: kam.email, name: kam.name)
      end
    end

    context 'without permissions' do
      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :assignProjectIncharge)
        expect(response.project).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'when the incharge is assigned or unassigned from project' do
      it 'sends the email to assigned person and unassigned provided not a current user' do
        perform_enqueued_jobs do
          _response, errors = formatted_response(query, current_user: super_user_b, key: :updateProject)
          expect(errors).to be_nil

          expect(ActionMailer::Base.deliveries.count).to eq(1)
          expect(ActionMailer::Base.deliveries.first).to have_attributes(
            subject: t('mailer.project.notify_incharge_assigned'),
            to: [kam.email]
          )
        end
      end
    end
  end

  def query
    <<~GQL
      mutation {
        assignProjectIncharge( input: { attributes: { projectId: "#{project.id}" inchargeId: "#{kam.id}" } } )
        { project { incharge { id name email } } }
      }
    GQL
  end
end
