# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::UnarchiveTask do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:task) { create(:task, :archived, taskable: project, assignee: super_user, owner: super_user) }

  describe '.resolve' do
    context 'with permissions' do
      it 'un archives the task and resets to its previous status' do
        response, errors = formatted_response(query, current_user: super_user, key: :unarchiveTask)
        expect(errors).to be_nil
        expect(response.task.status).to eq('To-Do')
      end

      it "resets the task to it's previous status" do
        task.update(status: :completed)
        task.update(status: :archived)

        response, errors = formatted_response(query, current_user: super_user, key: :unarchiveTask)
        expect(errors).to be_nil
        expect(response.task.status).to eq('Completed')
      end
    end

    context 'without permissions' do
      let!(:kam) { create(:user, :kam) }

      it 'forbids action' do
        response, errors = formatted_response(query, current_user: kam, key: :unarchiveTask)
        expect(response.task).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end

    context 'when the task is not currently archived' do
      before { task.update_column(:status, :in_progress) }

      it 'throws error' do
        response, errors = formatted_response(query, current_user: super_user, key: :unarchiveTask)
        expect(response.task).to be_nil
        expect(errors).to eq([t('project.task_not_archived')])
      end
    end
  end

  def query
    <<~GQL
      mutation {
        unarchiveTask(input: { id: "#{task.id}" } )
        { task { id title status dueDate assignee { id email } owner { id } } }
      }
    GQL
  end
end
