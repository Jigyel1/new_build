# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::DeleteTask do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:task) { create(:task, :archived, taskable: project, assignee: super_user, owner: super_user) }

  describe '.resolve' do
    context 'with permissions' do
      it 'deletes the task' do
        response, errors = formatted_response(query, current_user: super_user, key: :deleteTask)
        expect(errors).to be_nil
        expect(response.status).to be(true)
        expect { Projects::Task.find(task.id) }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :deleteTask)
        expect(response.task).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        deleteTask(input: { id: "#{task.id}" } )
        { status }
      }
    GQL
  end
end
