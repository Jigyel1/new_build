# frozen_string_literal: true

require 'rails_helper'

describe Projects::TaskUpdater do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:task) { create(:task, taskable: building, assignee: kam, owner: super_user) }
  let_it_be(:task_b) { create(:task, taskable: project, assignee: kam, owner: super_user) }
  let_it_be(:params) { { id: task.id, status: :completed } }
  let_it_be(:params_b) { { id: task_b.id, status: :completed } }

  describe '.activities' do
    context 'with buildings' do
      before { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activity in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.owner',
              previous_status: task.status,
              status: params[:status],
              type: task.taskable_type.demodulize,
              title: task.title,
              recipient_email: kam.email)
          )
        end
      end

      context 'as a recipient' do
        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.recipient',
              previous_status: task.status,
              status: params[:status],
              type: task.taskable_type.demodulize,
              title: task.title,
              owner_email: super_user.email)
          )
        end
      end

      context 'as a general user' do
        let!(:super_user_b) { create(:user, :super_user) }

        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.others',
              previous_status: task.status,
              status: params[:status],
              type: task.taskable_type.demodulize,
              title: task.title,
              owner_email: super_user.email,
              recipient_email: kam.email)
          )
        end
      end
    end

    context 'with projects' do
      before { described_class.new(current_user: super_user, attributes: params_b).call }

      context 'as an owner' do
        it 'returns activity in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.owner',
              previous_status: task_b.status,
              status: params_b[:status],
              type: task_b.taskable_type,
              title: task_b.title,
              recipient_email: kam.email)
          )
        end
      end

      context 'as a recipient' do
        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.recipient',
              previous_status: task_b.status,
              status: params_b[:status],
              type: task_b.taskable_type,
              title: task_b.title,
              owner_email: super_user.email)
          )
        end
      end

      context 'as a general user' do
        let!(:super_user_b) { create(:user, :super_user) }

        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_updated.others',
              previous_status: task_b.status,
              status: params_b[:status],
              type: task_b.taskable_type,
              title: task_b.title,
              owner_email: super_user.email,
              recipient_email: kam.email)
          )
        end
      end
    end
  end
end
