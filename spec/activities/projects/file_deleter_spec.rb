# frozen_string_literal: true

require 'rails_helper'

describe Projects::FileDeleter do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project, files: [file_upload]) }
  let_it_be(:building) { create(:building, project: project, files: [file_upload]) }
  let_it_be(:super_user_b) { create(:user, :super_user) }

  describe '.activities' do
    context 'with projects' do
      let_it_be(:params) { { id: project.files.first.id } }

      before { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activities in the first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_deleted.owner',
              filename: 'matrix.jpeg',
              type: 'Project')
          )
        end
      end

      context 'as a general user' do
        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_deleted.others',
              filename: 'matrix.jpeg',
              type: 'Project',
              owner_email: super_user.email)
          )
        end
      end
    end

    context 'with buildings' do
      let_it_be(:params) { { id: building.files.first.id } }

      before { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activities in the first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_deleted.owner',
              filename: 'matrix.jpeg',
              type: 'Building')
          )
        end
      end

      context 'as a general user' do
        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_deleted.others',
              filename: 'matrix.jpeg',
              type: 'Building',
              owner_email: super_user.email)
          )
        end
      end
    end
  end
end
