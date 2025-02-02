# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::ProjectCostUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project_cost) { create(:admin_toolkit_project_cost) }
  let_it_be(:params) { { arpu: 340, standard: 10_300 } }

  before_all { ::AdminToolkit::ProjectCostUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.project_cost_updated.owner',
            standard: params[:standard])
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
          t('activities.admin_toolkit.project_cost_updated.others',
            owner_email: super_user.email,
            standard: params[:standard])
        )
      end
    end
  end
end
