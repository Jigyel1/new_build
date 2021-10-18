# frozen_string_literal: true

require 'rails_helper'

describe Projects::FileUpdater do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project, files: [file_upload]) }
  let_it_be(:building) { create(:building, project: project, files: [file_upload]) }
  let_it_be(:file) { project.files.first }
  let_it_be(:file_b) { building.files.first }
  let_it_be(:params) { { id: file.id, name: 'test' } }
  let_it_be(:params_b) { { id: file_b.id, name: 'test 2' } }

  describe '.activities' do
    context 'with Project' do
      before { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activity in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_updated.owner',
              filename: params[:name],
              type: file.record_type.split('::').last)
          )
        end
      end

      context 'as a general user' do
        let!(:super_user_b) { create(:user, :super_user) }

        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_updated.others',
              filename: params[:name],
              type: file.record_type.split('::').last,
              owner_email: super_user.email)
          )
        end
      end
    end

    context 'with Building' do
      before { described_class.new(current_user: super_user, attributes: params_b).call }

      context 'as an owner' do
        it 'returns activity in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_updated.owner',
              filename: params_b[:name],
              type: file_b.record_type.split('::').last)
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
            t('activities.active_storage.attachment_file_updated.others',
              filename: params_b[:name],
              type: file_b.record_type.split('::').last,
              owner_email: super_user.email)
          )
        end
      end
    end
  end
end
