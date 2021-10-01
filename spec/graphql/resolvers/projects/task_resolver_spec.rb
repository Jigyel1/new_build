# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Resolvers::Projects::TaskResolver do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project, assignee: super_user) }

  let_it_be(:task) do
    create(
      :task,
      taskable: project,
      owner: super_user,
      assignee: super_user,
      title: 'Floor panelling',
      description: 'Ensure that the marble slabs are fitted well with proper drainage',
      due_date: 3.days.from_now
    )
  end

  describe '.resolve' do
    context 'with read permission' do
      it 'returns task details' do
        data, errors = formatted_response(query, current_user: super_user)
        expect(errors).to be_nil
        expect(data.task).to have_attributes(
          id: task.id,
          title: task.title,
          status: task.status,
          dueDate: task.due_date.to_s,
          description: task.description
        )

        expect(data.task.assignee).to have_attributes(
          id: super_user.id,
          name: super_user.name,
          email: super_user.email
        )
      end
    end

    context 'without read permission' do
      let!(:manager_commercialization) { create(:user, :manager_commercialization) }

      it 'forbids action' do
        data, errors = formatted_response(query, current_user: manager_commercialization)
        expect(data.task).to be_nil
        expect(errors).to eq(['Not Authorized'])
      end
    end
  end

  def query
    <<~GQL
      query { task(id: "#{task.id}")
        {
          id title status dueDate description
          owner { id name email } assignee { id name email }
        }
      }
    GQL
  end
end
