# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UpdateTask do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:task) { create(:task, taskable: building, assignee: kam, owner: super_user) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { status: :in_progress } }

      it 'updates the task' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateTask)
        expect(errors).to be_nil
        expect(response.task).to have_attributes(status: 'In Progress')
      end
    end

    context 'with invalid params' do
      let!(:params) { { status: nil } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :updateTask)
        expect(response.task).to be_nil
        expect(errors).to eq(["Status #{t('errors.messages.blank')}"])
      end
    end

    context 'without permissions' do
      let!(:params) { { status: :in_progress } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: kam, key: :updateTask)
        expect(response.task).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        updateTask( input: { attributes: { id: "#{task.id}" status: "#{args[:status]}" } } )
        { task { id title description status assignee { id email } owner { id email } } }
      }
    GQL
  end
end
