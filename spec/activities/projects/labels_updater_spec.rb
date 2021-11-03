# frozen_string_literal: true

require 'rails_helper'

describe Projects::LabelsUpdater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Assign KAM, Offer Needed') }
  let_it_be(:project) { create(:project, :from_info_manager) }

  let_it_be(:projects_label_group) do
    create(
      :projects_label_group,
      label_group: label_group,
      project: project,
      label_list: 'Prio 1, Prio 2'
    )
  end

  let_it_be(:params) { { id: projects_label_group.id } }
  before_all { described_class.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activities in the first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.projects.labels_updated.owner',
            project_name: project.name,
            status: project.status,
            label_list: projects_label_group.label_list.join(', '))
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
          t('activities.projects.labels_updated.others',
            project_name: project.name,
            status: project.status,
            label_list: projects_label_group.label_list.join(', '),
            owner_email: super_user.email)
        )
      end
    end
  end
end
