# frozen_string_literal: true

require 'rails_helper'

describe Projects::TaskUpdater do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:task) { create(:task, taskable: building, assignee: kam, owner: super_user) }
  let_it_be(:params) { { id: task.id } }

  before_all { described_class.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity in terms of first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.task_updated.owner')
        )
      end
    end

    context 'as a recipient' do
      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
        expect(errors).to be_nil
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.task_updated.recipient')
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.task_updated.others')
        )
      end
    end
  end
end
