# frozen_string_literal: true

require 'rails_helper'

describe Projects::Updater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:kam) { create(:user, :kam) }
  let_it_be(:project) { create(:project) }
  let_it_be(:params) { { id: project.id, status: 'Technical Analysis', assignee_id: kam.id } }

  before_all { ::Projects::Updater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.project.project_updated.owner',
            project_name: project.name,
            status: 'Technical Analysis')
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activities in third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.project.project_updated.others',
            project_name: project.name,
            status: 'Technical Analysis',
            owner_email: super_user.email)
        )
      end
    end
  end
end
