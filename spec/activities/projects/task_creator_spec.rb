# frozen_string_literal: true

require 'rails_helper'

describe Projects::TaskCreator do
  using TimeFormatter

  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:building) { create(:building, project: project) }
  let_it_be(:super_user_b) { create(:user, :super_user) }

  let_it_be(:params) do
    proc do |copy|
      {
        assignee_id: kam.id,
        title: 'Reminder',
        description: 'Send offer document to admins',
        taskable_type: 'Projects::Building',
        taskable_id: building.id,
        due_date: Date.current,
        copy_to_all_buildings: copy
      }
    end
  end

  describe '.activities' do
    context 'when copy to all buildings set to false' do
      before do
        described_class.new(
          current_user: super_user,
          attributes: params.call(false)
        ).call
      end

      context 'as an owner' do
        it 'returns activities in first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_created.owner',
              recipient_email: kam.email,
              title: 'Reminder')
          )
        end
      end

      context 'as a recipient' do
        it 'returns activities in second person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_created.recipient',
              owner_email: super_user.email,
              title: 'Reminder')
          )
        end
      end

      context 'as a general user' do
        it 'returns activities in third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_created.others',
              recipient_email: kam.email,
              owner_email: super_user.email,
              title: 'Reminder')
          )
        end
      end
    end

    context 'when copy to all buildings set to true' do
      before do
        described_class.new(
          current_user: super_user,
          attributes: params.call(true)
        ).call
      end

      context 'as an owner' do
        it 'returns activities in first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_created_and_copied.owner',
              recipient_email: kam.email,
              title: 'Reminder')
          )
        end
      end

      context 'as a recipient' do
        it 'returns activities in second person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: kam)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_created_and_copied.recipient',
              owner_email: super_user.email,
              title: 'Reminder')
          )
        end
      end

      context 'as a general user' do
        it 'returns activities in third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.projects.task_created_and_copied.others',
              recipient_email: kam.email,
              owner_email: super_user.email,
              title: 'Reminder')
          )
        end
      end
    end
  end
end
