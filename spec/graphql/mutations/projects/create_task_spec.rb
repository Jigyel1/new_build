# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Mutations::Projects::CreateTask do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
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
          status: 'todo',
          dueDate: Date.current.date_str,
          projectName: project.name,
          buildingId: building.id,
          projectId: project.id
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

    context 'with copy to all buildings flag set' do
      let_it_be(:building_b) { create(:building, project: project) }
      let_it_be(:building_c) { create(:building, project: project) }
      let_it_be(:building_d) { create(:building, project: project) }

      context 'when taskable is a building' do
        let!(:params) do
          {
            taskable_type: 'Projects::Building',
            taskable_id: building.id,
            due_date: Date.tomorrow,
            copy_to_all_buildings: true
          }
        end

        it "clones task for all buildings belonging to the building's project" do
          _, errors = formatted_response(query(params), current_user: super_user, key: :createTask)
          expect(errors).to be_nil
          expect(Projects::Task.count).to eq(4)
          expect(Projects::Task.pluck(:taskable_id)).to match_array(
            [building.id, building_b.id, building_c.id, building_d.id]
          )
        end
      end

      context 'when taskable is a project' do
        let!(:params) do
          {
            taskable_type: 'Project',
            taskable_id: project.id,
            due_date: Date.tomorrow,
            copy_to_all_buildings: true
          }
        end

        it 'clones task for all buildings belonging to the project' do
          _, errors = formatted_response(query(params), current_user: super_user, key: :createTask)
          expect(errors).to be_nil
          expect(Projects::Task.count).to eq(5)
          expect(Projects::Task.pluck(:taskable_id)).to match_array(
            [project.id, building.id, building_b.id, building_c.id, building_d.id]
          )
        end
      end
    end
  end

  def query(args = {})
    copy_task = args[:copy_to_all_buildings] || false

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
              copyToAllBuildings: #{copy_task}
            }
          }
        )
        { task { id title status description dueDate buildingId projectId hostUrl buildingName
                projectName owner { id email } assignee { id email } } }
      }
    GQL
  end
end
