# frozen_string_literal: true

require 'rails_helper'

describe AdminToolkit::LabelsUpdater do
  let_it_be(:super_user) { create(:user, :super_user) }
  let_it_be(:label_group) { create(:admin_toolkit_label_group, label_list: 'Prio 1, Prio 2') }
  let_it_be(:params) { { id: label_group.id, label_list: 'On Hold, Prio N' } }

  before_all { ::AdminToolkit::LabelsUpdater.new(current_user: super_user, attributes: params).call }

  describe '.activities' do
    context 'as an owner' do
      it 'returns activity text in terms of a first person' do
        activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
        expect(errors).to be_nil
        expect(activities.size).to eq(1)
        expect(activities.dig(0, :displayText)).to eq(
          t('activities.admin_toolkit.label_group_updated.owner',
            trackable_name: label_group.name,
            label_list: params[:label_list])
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
          t('activities.admin_toolkit.label_group_updated.others',
            trackable_name: label_group.name,
            owner_email: super_user.email,
            label_list: params[:label_list])
        )
      end
    end
  end
end
