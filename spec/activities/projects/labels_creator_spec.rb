# frozen_string_literal: true

require 'rails_helper'

describe Projects::LabelsCreator do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:project) { create(:project, :from_info_manager) }
  let_it_be(:params) { { project_id: project.id, label_list: 'Prio 3, On Hold' } }

  before_all { described_class.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity in terms of first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.label_group_created.owner')
        )
      end
    end

    context 'as a general user' do
      let!(:super_user_b) { create(:user, :super_user) }

      it 'returns activity text in terms of a third person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.label_group_created.others')
        )
      end
    end
  end
end
