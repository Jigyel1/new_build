# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::CreateTask do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }

  describe '.resolve' do
    context 'with valid params' do
      let!(:params) { { taskable_type: 'Projects::Building', taskable_id: building.id, due_date: Date.current } }

      it 'creates the address book' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createTask)
        expect(errors).to be_nil
        task = response.task

        expect(task).to have_attributes(
                          title: 'Kitchen Wiring',
                          description: '3 Kitchens in the top floor need to be wired before paneling.',
                          status: 'To-Do',
                          dueDate: Date.current.to_s
                        )

        expect(task.owner).to have_attributes(email: super_user.email, id: super_user.id)
        expect(task.assignee).to have_attributes(email: kam.email, id: kam.id)
      end
    end

    context 'without valid params' do
      let!(:params) { { taskable_id: building.id, taskable_type: 'Projects::Building' } }

      it 'responds with error' do
        response, errors = formatted_response(query(params), current_user: super_user, key: :createTask)
        expect(response.task).to be_nil
        expect(errors).to eq(["Due date #{t('errors.messages.blank')}"])
      end
    end

    context 'without permissions' do
      let!(:manager_presales) { create(:user, :manager_presales) }
      let!(:params) { { taskable_type: 'Projects::Building', taskable_id: building.id, due_date: Date.current } }

      it 'forbids action' do
        response, errors = formatted_response(query(params), current_user: manager_presales, key: :createTask)
        expect(response.task).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query(args = {})
    <<~GQL
      mutation {
        createTask(
          input: {
            attributes: {
              title: "Kitchen Wiring"
              description: "3 Kitchens in the top floor need to be wired before paneling."
              status: "To-Do"
              dueDate: "#{args[:due_date]}"
              assigneeId: "#{kam.id}"
              taskableType: "#{args[:taskable_type]}"
              taskableId: "#{args[:taskable_id]}"
            }
          }
        )
        { task { id title status description dueDate owner { id email } assignee { id email } } }
      }
    GQL
  end
end