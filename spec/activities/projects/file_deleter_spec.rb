# frozen_string_literal: true

require 'rails_helper'

describe Projects::FileDeleter do
  let_it_be(:super_user) { create(:user, :super_user, with_permissions: { project: :update }) }
  let_it_be(:project) { create(:project, files: [file_upload]) }
  let_it_be(:building) { create(:building, project: project, files: [file_upload]) }
  let_it_be(:file) { project.files.first }
  let_it_be(:file_b) { building.files.first }
  let_it_be(:params) { { id: file.id } }
  let_it_be(:params_b) { { id: file_b.id } }

  describe '.activities' do
    context 'with Project' do
      before { described_class.new(current_user: super_user, attributes: params).call }

      context 'as an owner' do
        it 'returns activity in terms of first person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user)
          expect(errors).to be_nil
          expect(activities.size).to eq(1)
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_deleted.owner',
              filename: file.blob[:filename],
              type: file.record_type.demodulize)
          )
        end
      end

      context 'as a general user' do
        let!(:super_user_b) { create(:user, :super_user) }

        it 'returns activity text in terms of a third person' do
          activities, errors = paginated_collection(:activities, activities_query, current_user: super_user_b)
          expect(errors).to be_nil
          expect(activities.dig(0, :displayText)).to eq(
            t('activities.active_storage.attachment_file_deleted.others',
              filename: file.blob[:filename],
              type: file.record_type.demodulize,
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
            t('activities.active_storage.attachment_file_deleted.owner',
              filename: file_b.blob[:filename],
              type: file_b.record_type.demodulize)
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
            t('activities.active_storage.attachment_file_deleted.others',
              filename: file_b.blob[:filename],
              type: file_b.record_type.demodulize,
              owner_email: super_user.email)
          )
        end
      end
    end
  end
end
