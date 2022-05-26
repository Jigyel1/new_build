# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::ExportActivities do
  include ActivitiesSpecHelper

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:administrator) { create(:user, :administrator) }
  let_it_be(:super_user_a) { create(:user, :super_user) }
  let_it_be(:management) { create(:user, :management) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:kam_a) { create(:user, :kam) }
  let_it_be(:project) { create(:project, assignee: kam, kam_assignee: kam, project_nr: '2222') }
  let_it_be(:building) { create(:building, project: project, external_id: '112233') }
  before_all { create_activities }

  describe '.resolve' do
    context 'when send without any arguments' do
      it 'exports all activities to csv' do
        response, errors = formatted_response(query, current_user: super_user, key: :exportActivities)
        expect(errors).to be_nil
        expect { (uri = URI.parse(response.url)) && uri.host }.not_to raise_error
      end
    end

    context 'when trackable id and user id is provided in arguments' do
      before do
        create(
          :activity,
          owner: super_user,
          trackable: project,
          action: :project_created,
          log_data: {
            owner_email: super_user.email,
            parameters: { entry_type: project.entry_type, project_name: project.name }
          }
        )
      end

      let(:param) { { trackable_id: project.id, user_id: super_user.id } }

      it 'exports projects specific to trackable id and user id' do
        response, errors = formatted_response(query(param), current_user: super_user, key: :exportActivities)
        expect(errors).to be_nil
        expect { (uri = URI.parse(response.url)) && uri.host }.not_to raise_error
      end
    end
  end

  def query(args = {})
    user_id = args[:user_id] || ''
    trackable_id = args[:trackable_id] || ''

    <<~GQL
      mutation {
        exportActivities(
        input: { attributes: {trackableId: "#{user_id}" userIds: ["#{trackable_id}"]}}) { url }
      }
    GQL
  end
end
