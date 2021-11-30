# frozen_string_literal: true

require 'rails_helper'

describe Projects::TaskUpdater do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:super_user_b) { create(:user, :super_user) }

  describe '.activities' do
    context 'with buildings' do
      let_it_be(:task) { create(:task, taskable: building, assignee: kam, owner: super_user) }
      let_it_be(:params) { { id: task.id, status: :in_progress } }
      before_all { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activities in the first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.owner',
              previous_status: task.status.titleize,
              status: 'In Progress',
              type: 'Building',
              title: task.title,
              recipient_email: kam.email)
          )
        end
      end

      context 'as a recipient' do
        it 'returns activities in second person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.recipient',
              previous_status: task.status.titleize,
              status: 'In Progress',
              type: 'Building',
              title: task.title,
              owner_email: super_user.email)
          )
        end
      end

      context 'as a general user' do
        it 'returns activities in third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.others',
              previous_status: task.status.titleize,
              status: 'In Progress',
              type: 'Building',
              title: task.title,
              owner_email: super_user.email,
              recipient_email: kam.email)
          )
        end
      end
    end

    context 'with projects' do
      let_it_be(:task) { create(:task, taskable: project, assignee: kam, owner: super_user) }
      let_it_be(:params) { { id: task.id, status: :completed } }
      before_all { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activities in first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.owner',
              previous_status: task.status.titleize,
              status: 'Completed',
              type: 'Project',
              title: task.title,
              recipient_email: kam.email)
          )
        end
      end

      context 'as a recipient' do
        it 'returns activities in second person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.recipient',
              previous_status: task.status.titleize,
              status: 'Completed',
              type: 'Project',
              title: task.title,
              owner_email: super_user.email)
          )
        end
      end

      context 'as a general user' do
        it 'returns activities in third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.others',
              previous_status: task.status.titleize,
              status: 'Completed',
              type: 'Project',
              title: task.title,
              owner_email: super_user.email,
              recipient_email: kam.email)
          )
        end
      end
    end
  end
end
