# frozen_string_literal: true

require 'rails_helper'

describe Projects::TaskCreator do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:params) do
    { assignee_id: kam.id,
      title: 'Test',
      description: 'test test test',
      taskable_type: 'Projects::Building',
      taskable_id: building.id,
      due_date: Date.current }
  end

  before_all { described_class.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity in terms of first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.task_created.owner')
        )
      end
    end

    context 'as a recipient' do
      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
        expect(errors).to be_nil
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.task_created.recipient')
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.task_created.others')
        )
      end
    end
  end
end
